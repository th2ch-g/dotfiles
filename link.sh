#!/bin/bash
set -e

# cwd check
if [ ! -e $PWD/link.sh ]; then
    echo "link.sh is not detected"
    echo "execute ./link.sh in dotfiles directory"
    exit 1
fi

DOTFILES_DIR=$PWD
source "$DOTFILES_DIR/lib/utils.sh"

USAGE='
link.sh:
    dotfiles linker / copier / unlinker

USAGE:
    ./link.sh [FLAGS]

EXAMPLE:
    ./link.sh                            only OS check
    ./link.sh --vim --zsh --tmux --git   dotfiles link
    ./link.sh --unlink                   all dotfiles unlink

OPTIONS:
    -h, --help              print help
    -u, --unlink            all dotfiles unlink
        --vim               vim dotfiles link
        --zsh               zsh dotfiles link
        --tmux              tmux dotfiles link
        --git               git dotfiles link
        --alacritty         alacritty dotfiles link
        --neovim            neovim dotfiles link
        --yabai             yabai dotfiles link
        --skhd              skhd dotfiles link
        --aerospace         aerospace dotfiles link
        --gemini            gemini dotfiles link
        --codex             codex dotfiles link
        --claude            claude dotfiles link
        --ssh               ssh config file copy
        --bash              bash profile link (not recommend)
        --cp                use cp instead of ln
        --rm                use rm instead of unlink
'

XDG_CONFIG_HOME="${HOME}/.config"

# mode flags
unlink_flag=false
cp_flag=false
rm_flag=false

# enabled tools (populated by option parser)
tools=()

has_tool() {
    local t
    for t in "${tools[@]}"; do
        [[ "$t" == "$1" ]] && return 0
    done
    return 1
}

create_link() {
    local src=$1
    local dest=$2
    if $cp_flag; then
        cp -r "$src" "$dest" && print_info "Copied $(basename "$dest")"
    else
        ln -nsi "$src" "$dest" && print_info "Linked $(basename "$dest")"
    fi
}
remove_link() {
    local target=$1
    if $rm_flag; then
        rm -ir "$target" && print_info "Removed $(basename "$target")"
    else
        if [ -L "$target" ]; then
            unlink "$target" && print_info "Unlinked $(basename "$target")"
        fi
    fi
}
do_link() {
    local name=$1 src=$2 dest=$3
    print_info "$name link start"
    create_link "$src" "$dest"
    print_info "$name link done"
}


# option parser
while :;
do
    case $1 in
        -h | --help)
            echo "$USAGE" >&1
            exit 0
            ;;
        -u | --unlink)
            unlink_flag=true
            break
            ;;
        --vim)            tools+=(vim)       ;;
        --zsh)            tools+=(zsh)       ;;
        --tmux)           tools+=(tmux)      ;;
        --git)            tools+=(git)       ;;
        --alacritty)      tools+=(alacritty) ;;
        --neovim)         tools+=(neovim)    ;;
        --ssh)            tools+=(ssh)       ;;
        --bash)           tools+=(bash)      ;;
        --cp)             cp_flag=true       ;;
        --rm)             rm_flag=true       ;;
        --yabai)          tools+=(yabai)     ;;
        --skhd)           tools+=(skhd)      ;;
        --aerospace)      tools+=(aerospace) ;;
        --gemini)         tools+=(gemini)    ;;
        --codex)          tools+=(codex)     ;;
        --claude)         tools+=(claude)    ;;
       --)
            shift
            break
            ;;
        -?*)
            print_error "Unknown option: $1"
            exit 1
            ;;
        *)
            break
    esac
    shift
done

# OS check
detect_os
print_info "detect $OS OS"

# CPU check
arch=$(uname -m)
print_info "detect $arch CPU"

if [ ! -d ${XDG_CONFIG_HOME} ]; then
    mkdir -p ${XDG_CONFIG_HOME}
fi

if $unlink_flag || $rm_flag; then
    print_info "Start unlink dotfiles"
    set +e
    print_warn "Ignore error"

    # $HOME/dotfiles
    for dotfile in .bash_profile .gemini .codex .claude;
    do
        remove_link $HOME/$dotfile
    done

    # $XDG_CONFIG_HOME/dotfiles
    for target in git zsh sheldon tmux alacritty vim nvim yabai skhd aerospace;
    do
        remove_link ${XDG_CONFIG_HOME}/$target
    done
    remove_link ${HOME}/.zshenv

    print_info "dotfiles unlink done"
    set -e
fi

# vim link
if has_tool vim; then
    do_link "vim" "${PWD}/vim" "${XDG_CONFIG_HOME}/vim"
    if command -v vim >/dev/null 2>&1; then
        set +e
        export VIM_AI=1
        vim -e -c "JetpackSync" -c "qa"
        set -e
    fi
fi

# zsh link
if has_tool zsh; then
    print_info "zsh link start"
    create_link ${PWD}/zsh ${XDG_CONFIG_HOME}/zsh
    create_link ${PWD}/zsh/.zshenv ${HOME}/.zshenv
    create_link ${PWD}/sheldon ${XDG_CONFIG_HOME}/sheldon
    if [[ ! -f $XDG_CONFIG_HOME/zsh/.zshrc_local ]]; then
        touch $XDG_CONFIG_HOME/zsh/.zshrc_local
    fi
    if [[ ! -f $XDG_CONFIG_HOME/zsh/.zshenv_local ]]; then
        touch $XDG_CONFIG_HOME/zsh/.zshenv_local
    fi
    print_info "zsh link done"
fi

# tmux link
if has_tool tmux; then
    do_link "tmux" "${PWD}/tmux" "${XDG_CONFIG_HOME}/tmux"
fi

# git link
if has_tool git; then
    do_link "git" "${PWD}/git" "${XDG_CONFIG_HOME}/git"
fi

# alacritty link
if has_tool alacritty; then
    do_link "alacritty" "${PWD}/alacritty/" "${XDG_CONFIG_HOME}/alacritty"
fi

# neovim link
if has_tool neovim; then
    do_link "neovim" "${PWD}/nvim/" "${XDG_CONFIG_HOME}/nvim"
    if command -v nvim >/dev/null 2>&1; then
        export VIM_AI=1
        set +e
        nvim --headless "+Lazy! update" +qa
        set -e
    fi
fi

# ssh config file copy
if has_tool ssh; then
    print_info "ssh config file copy start"
    if [ ! -d ${HOME}/.ssh ]; then
        mkdir -p ${HOME}/.ssh
        print_info "${HOME}/.ssh/ is created"
    fi
    if [ ! -e ${HOME}/.ssh/config ]; then
        cp ${PWD}/ssh/config ${HOME}/.ssh/config
        print_info "ssh config file copy done"
    else
        print_warn "${HOME}/.ssh/config is already exist"
    fi
fi

# bash link
if has_tool bash; then
    do_link "bash" "${PWD}/bash/.bash_profile" "${HOME}/.bash_profile"
fi

# yabai
if has_tool yabai && [[ $OS == "Mac" ]]; then
    do_link "yabai" "${PWD}/yabai" "${XDG_CONFIG_HOME}/yabai"
    if command -v yabai >/dev/null 2>&1; then
        yabai --start-service
        yabai --restart-service
    fi
fi

# skhd
if has_tool skhd && [[ $OS == "Mac" ]]; then
    do_link "skhd" "${PWD}/skhd" "${XDG_CONFIG_HOME}/skhd"
    if command -v skhd >/dev/null 2>&1; then
        skhd --start-service
        skhd --restart-service
    fi
fi

# aerospace
if has_tool aerospace && [[ $OS == "Mac" ]]; then
    do_link "aerospace" "${PWD}/aerospace" "${XDG_CONFIG_HOME}/aerospace"
fi

# gemini
if has_tool gemini; then
    do_link "gemini" "${PWD}/gemini" "${HOME}/.gemini"
fi

# codex
if has_tool codex; then
    do_link "codex" "${PWD}/codex" "${HOME}/.codex"
fi

# claude
if has_tool claude; then
    do_link "claude" "${PWD}/claude" "${HOME}/.claude"
    if command -v claude >/dev/null 2>&1; then
        set +e
        claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp

        # claude mcp add serena \
        #     --scope user \
        #     -- uvx \
        #     --from git+https://github.com/oraios/serena \
        #     serena-mcp-server \
        #     --context claude-code \
        #     --project . \
        #     --enable-web-dashboard false

        # essential skills
        # claude plugin marketplace add anthropics/skills
        # claude plugin install document-skills@anthropic-agent-skills
        # claude plugin install example-skills@anthropic-agent-skills

        # financial skill
        # claude plugin marketplace add anthropics/financial-services-plugins
        # claude plugin install financial-analysis@financial-services-plugins
        # claude plugin install investment-banking@financial-services-plugins
        # claude plugin install equity-research@financial-services-plugins
        # claude plugin install private-equity@financial-services-plugins
        # claude plugin install wealth-management@financial-services-plugins

        # official plugins
        # claude plugin marketplace add anthropics/claude-plugins-official
        # claude plugin install agent-sdk-dev@claude-plugins-official
        # claude plugin install asana@claude-plugins-official
        # claude plugin install atlassian@claude-plugins-official
        # claude plugin install clangd-lsp@claude-plugins-official
        # claude plugin install claude-code-setup@claude-plugins-official
        # claude plugin install claude-md-management@claude-plugins-official
        # claude plugin install code-review@claude-plugins-official
        # claude plugin install code-simplifier@claude-plugins-official
        # claude plugin install commit-commands@claude-plugins-official
        # claude plugin install csharp-lsp@claude-plugins-official
        # claude plugin install explanatory-output-style@claude-plugins-official
        # claude plugin install feature-dev@claude-plugins-official
        # claude plugin install figma@claude-plugins-official
        # claude plugin install firebase@claude-plugins-official
        # claude plugin install frontend-design@claude-plugins-official
        # claude plugin install github@claude-plugins-official
        # claude plugin install gitlab@claude-plugins-official
        # claude plugin install gopls-lsp@claude-plugins-official
        # claude plugin install greptile@claude-plugins-official
        # claude plugin install hookify@claude-plugins-official
        # claude plugin install jdtls-lsp@claude-plugins-official
        # claude plugin install kotlin-lsp@claude-plugins-official
        # claude plugin install learning-output-style@claude-plugins-official
        # claude plugin install linear@claude-plugins-official
        # claude plugin install lua-lsp@claude-plugins-official
        # claude plugin install php-lsp@claude-plugins-official
        # claude plugin install pinecone@claude-plugins-official
        # claude plugin install playground@claude-plugins-official
        # claude plugin install plugin-dev@claude-plugins-official
        # claude plugin install pr-review-toolkit@claude-plugins-official
        # claude plugin install pyright-lsp@claude-plugins-official
        # claude plugin install ralph-loop@claude-plugins-official
        # claude plugin install rust-analyzer-lsp@claude-plugins-official
        # claude plugin install security-guidance@claude-plugins-official
        # claude plugin install serena@claude-plugins-official
        # claude plugin install skill-creator@claude-plugins-official
        # claude plugin install slack@claude-plugins-official
        # claude plugin install stripe@claude-plugins-official
        # claude plugin install supabase@claude-plugins-official
        # claude plugin install swift-lsp@claude-plugins-official
        # claude plugin install typescript-lsp@claude-plugins-official
        # claude plugin install vercel@claude-plugins-official
        set -e
    fi
fi

echo "[INFO] done" >&1
