#!/usr/bin/env bash
#
# Claude Code custom statusLine. Reads the session JSON from stdin and prints a
# two-line status:
#   line 1 (environment): <model>  effort:<lvl>  style:<name>  think  <branch>
#                         <repo>  <cwd>  «<session-name>»
#   line 2 (metrics):     ctx <used>k used / <free>k free (<pct>%)  out <n>k
#                         cache <create>k/<read>k  compact ~<n>%  PR#<n> <state>
#                         +<add> -<rem>
#                         usage 5h <pct>% (<reset>) 7d <pct>% (<reset>)
#                         <elapsed>  $<cost>
# Schema: https://code.claude.com/docs/en/statusline
#
# No `set -e` on purpose: Claude Code blanks the status line on any non-zero
# exit, so we degrade gracefully (missing fields just drop out, and the whole
# second line collapses when empty) instead of failing hard.

input=$(cat)

cyan=$'\033[36m'
green=$'\033[32m'
blue=$'\033[34m'
yellow=$'\033[33m'
red=$'\033[31m'
magenta=$'\033[35m'
dim=$'\033[2m'
reset=$'\033[0m'

# Compact "6d3h" / "1h23m" / "45m" / "30s" from a second count; clamps to 0.
# Days are carried so 7-day reset windows don't render as a huge hour count.
fmt_dur() {
    local s=$1 d h m
    [[ "$s" =~ ^-?[0-9]+$ ]] || {
        printf '0s'
        return
    }
    [ "$s" -lt 0 ] && s=0
    d=$((s / 86400))
    h=$(((s % 86400) / 3600))
    m=$(((s % 3600) / 60))
    if [ "$d" -gt 0 ]; then
        printf '%dd%dh' "$d" "$h"
    elif [ "$h" -gt 0 ]; then
        printf '%dh%dm' "$h" "$m"
    elif [ "$m" -gt 0 ]; then
        printf '%dm' "$m"
    else
        printf '%ds' "$s"
    fi
}

# jq powers the rich line; without it (e.g. a minimal Linux host) fall back to
# directory + branch only, on a SINGLE line, so the bar never silently blanks.
if ! command -v jq > /dev/null 2>&1; then
    branch=$(git branch --show-current 2> /dev/null)
    printf '%s%s%s%s' "$blue" "${PWD/#"$HOME"/\~}" "$reset" "${branch:+ ${green}${branch}${reset}}"
    exit 0
fi

# One jq pass, one field per line. A while-read loop preserves empty fields;
# `read -a` with a whitespace IFS would collapse an empty middle field (e.g. a
# missing cwd) and shift every later column. Keep this list and the index
# assignments below in lock-step.
fields=()
while IFS= read -r f; do
    fields+=("$f")
done < <(
    printf '%s' "$input" | jq -r \
        '.model.display_name // "?",
		 (.effort.level // ""),
		 (.output_style.name // ""),
		 (.thinking.enabled // false),
		 .workspace.current_dir // .cwd // "",
		 (.workspace.repo.owner // ""),
		 (.workspace.repo.name // ""),
		 (.session_name // ""),
		 (.context_window.used_percentage // ""),
		 (.context_window.total_input_tokens // ""),
		 (.context_window.total_output_tokens // ""),
		 (.context_window.context_window_size // ""),
		 (.pr.number // ""),
		 (.pr.review_state // ""),
		 (.cost.total_lines_added // ""),
		 (.cost.total_lines_removed // ""),
		 (.cost.total_cost_usd // ""),
		 (.cost.total_duration_ms // ""),
		 (.rate_limits.five_hour.used_percentage // ""),
		 (.rate_limits.five_hour.resets_at // ""),
		 (.rate_limits.seven_day.used_percentage // ""),
		 (.rate_limits.seven_day.resets_at // ""),
		 (.context_window.current_usage.cache_creation_input_tokens // ""),
		 (.context_window.current_usage.cache_read_input_tokens // "")'
)
model=${fields[0]}
effort=${fields[1]}
style=${fields[2]}
thinking=${fields[3]}
cwd=${fields[4]}
repo_owner=${fields[5]}
repo_name=${fields[6]}
session_name=${fields[7]}
used_pct=${fields[8]}
in_tok=${fields[9]}
out_tok=${fields[10]}
win_size=${fields[11]}
pr_num=${fields[12]}
pr_state=${fields[13]}
lines_add=${fields[14]}
lines_rem=${fields[15]}
cost=${fields[16]}
duration_ms=${fields[17]}
rl5=${fields[18]}
rl5_reset=${fields[19]}
rl7=${fields[20]}
rl7_reset=${fields[21]}
cache_create=${fields[22]}
cache_read=${fields[23]}

[ -z "$cwd" ] && cwd=$PWD
# Full path, with $HOME abbreviated to ~ to keep it short.
disp_dir=${cwd/#"$HOME"/\~}
# Git branch is NOT in the JSON; query it from the session's directory.
branch=$(git -C "$cwd" branch --show-current 2> /dev/null)

# ---- Line 1: environment ---------------------------------------------------
line1="${cyan}${model}${reset}"
[ -n "$effort" ] && line1="${line1}  ${yellow}effort:${effort}${reset}"
[ -n "$style" ] && line1="${line1}  ${magenta}style:${style}${reset}"
[ "$thinking" = "true" ] && line1="${line1}  ${magenta}think${reset}"
[ -n "$branch" ] && line1="${line1}  ${green}${branch}${reset}"
[ -n "$repo_owner" ] && [ -n "$repo_name" ] && line1="${line1}  ${dim}${repo_owner}/${repo_name}${reset}"
line1="${line1}  ${blue}${disp_dir}${reset}"
[ -n "$session_name" ] && line1="${line1}  ${dim}«${session_name}»${reset}"

# ---- Line 2: metrics -------------------------------------------------------
line2=""

# Context window: used vs free tokens plus % used; color deepens as it fills.
if [ -n "$used_pct" ]; then
    pct=${used_pct%.*}
    [ -z "$pct" ] && pct=0
    if [ "$pct" -ge 80 ]; then
        ctx_c=$red
    elif [ "$pct" -ge 60 ]; then
        ctx_c=$yellow
    else
        ctx_c=$green
    fi
    # Guard arithmetic against non-numeric input before computing token counts.
    if [[ "$in_tok" =~ ^[0-9]+$ ]] && [[ "$win_size" =~ ^[0-9]+$ ]] && [ "$win_size" -gt 0 ]; then
        used_k=$((in_tok / 1000))
        free_k=$(((win_size - in_tok) / 1000))
        line2="${line2}  ${ctx_c}ctx ${used_k}k used / ${free_k}k free (${pct}%)${reset}"
    else
        line2="${line2}  ${ctx_c}ctx ${pct}% used${reset}"
    fi
    # Output tokens from the most recent response. Gate on >=1000 so sub-1k
    # counts don't render a misleading "out 0k".
    if [[ "$out_tok" =~ ^[0-9]+$ ]] && [ "$out_tok" -ge 1000 ]; then
        line2="${line2}  ${dim}out $((out_tok / 1000))k${reset}"
    fi
    # Cache breakdown (creation/read) from the last API call's current_usage;
    # absent before the first call and right after /compact (current_usage null).
    if [[ "$cache_create" =~ ^[0-9]+$ ]] && [[ "$cache_read" =~ ^[0-9]+$ ]] &&
        [ $((cache_create + cache_read)) -gt 0 ]; then
        line2="${line2}  ${dim}cache $((cache_create / 1000))k/$((cache_read / 1000))k${reset}"
    fi

    # Approx. headroom until auto-compact. The threshold is NOT in the JSON:
    # Claude Code auto-compacts around 95% of the window by default (reported
    # lower, ~84%, in practice). Override with CLAUDE_AUTOCOMPACT_PCT_OVERRIDE.
    compact_pct=${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-95}
    [[ "$compact_pct" =~ ^[0-9]+$ ]] || compact_pct=95
    until_c=$((compact_pct - pct))
    [ "$until_c" -lt 0 ] && until_c=0
    if [ "$until_c" -le 10 ]; then
        cc=$red
    elif [ "$until_c" -le 25 ]; then
        cc=$yellow
    else
        cc=$green
    fi
    line2="${line2}  ${cc}compact ~${until_c}%${reset}"
fi

# Open PR for the current branch, colored by review state.
if [ -n "$pr_num" ]; then
    case "$pr_state" in
        approved) pr_c=$green ;;
        changes_requested) pr_c=$red ;;
        pending) pr_c=$yellow ;;
        draft) pr_c=$dim ;;
        *) pr_c=$reset ;;
    esac
    pr_seg="PR#${pr_num}"
    [ -n "$pr_state" ] && pr_seg="${pr_seg} ${pr_state}"
    line2="${line2}  ${pr_c}${pr_seg}${reset}"
fi

# Lines changed this session (added green / removed red); shown only when nonzero.
add_ok=0
rem_ok=0
[[ "$lines_add" =~ ^[0-9]+$ ]] && [ "$lines_add" -gt 0 ] && add_ok=1
[[ "$lines_rem" =~ ^[0-9]+$ ]] && [ "$lines_rem" -gt 0 ] && rem_ok=1
if [ "$add_ok" = 1 ] || [ "$rem_ok" = 1 ]; then
    diff_seg=""
    [ "$add_ok" = 1 ] && diff_seg="${green}+${lines_add}${reset}"
    [ "$rem_ok" = 1 ] && diff_seg="${diff_seg:+${diff_seg} }${red}-${lines_rem}${reset}"
    line2="${line2}  ${diff_seg}"
fi

# Subscription usage limits with time-until-reset (Claude.ai Pro/Max only;
# absent on API-key auth). resets_at is Unix epoch seconds.
if [ -n "$rl5" ] || [ -n "$rl7" ]; then
    now=$(date +%s)
    usage_str="usage"
    if [ -n "$rl5" ]; then
        usage_str="${usage_str} 5h ${rl5%.*}%"
        if [[ "$rl5_reset" =~ ^[0-9]+$ ]]; then
            usage_str="${usage_str} ($(fmt_dur $((rl5_reset - now))))"
        fi
    fi
    if [ -n "$rl7" ]; then
        usage_str="${usage_str} 7d ${rl7%.*}%"
        if [[ "$rl7_reset" =~ ^[0-9]+$ ]]; then
            usage_str="${usage_str} ($(fmt_dur $((rl7_reset - now))))"
        fi
    fi
    line2="${line2}  ${magenta}${usage_str}${reset}"
fi

# Session wall-clock elapsed time.
if [[ "$duration_ms" =~ ^[0-9]+$ ]] && [ "$duration_ms" -gt 0 ]; then
    line2="${line2}  ${dim}$(fmt_dur $((duration_ms / 1000)))${reset}"
fi

# Session cost: shown only once it rounds to at least $0.01 (cuts noise).
if [ -n "$cost" ]; then
    cost_fmt=$(printf '%.2f' "$cost" 2> /dev/null)
    [ -n "$cost_fmt" ] && [ "$cost_fmt" != "0.00" ] && line2="${line2}  ${dim}\$${cost_fmt}${reset}"
fi

# Strip the leading separator and emit. The second line is printed only when it
# has content, so an early session (no metrics yet) stays a clean single line.
line2=${line2#  }
if [ -n "$line2" ]; then
    printf '%s\n%s' "$line1" "$line2"
else
    printf '%s' "$line1"
fi
