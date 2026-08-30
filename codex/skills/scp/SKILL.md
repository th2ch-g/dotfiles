---
name: scp
description: >-
  Print a copy-paste-ready scp one-liner for downloading files used by the
  current task from the current SSH server. Use when the user invokes $scp
  with a file, artifact, or task reference.
---

# SCP Download Command

Return a command that the user can run on their local machine to download the
requested file or files from the current remote server.

- Resolve task references such as "files used for X" from the conversation and
  files actually used for that task. Ask which files when the selection is
  materially ambiguous.
- Verify that every selected source is a regular file on the current remote
  server and resolve it to its full absolute path.
- Use a concrete SSH username, reachable host or alias, and port. Prefer
  connection details already supplied by the user or available from the
  current SSH session. If a copy-paste-ready endpoint cannot be determined,
  ask for the reachable SSH host or alias instead of emitting a placeholder.
- Print exactly one `scp` command in a `bash` code block, with no surrounding prose.
- Start the command with `scp`. Add `-P <port>` only for a known non-default
  port that is not covered by an SSH alias.
- Shell-quote each complete remote source operand in the form
  `user@host:/absolute/path`. Put all requested files in the same command and
  use `.` as the final local destination.
- Do not prepend `mkdir`, `cd`, or `ssh`; do not use `&&`, variables, `~`,
  globs, command substitutions, or placeholders.
- If multiple files have the same basename, ask the user to choose instead of
  generating a command that may overwrite a download.
- Only display the command. Do not execute `scp`.
