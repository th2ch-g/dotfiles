---
name: scp
description: >-
  Print copy-paste-ready scp commands for downloading files used by the
  current task from the current SSH server, including multiple same-named
  files that need distinct local names. Use when the user invokes $scp with a
  file, artifact, or task reference.
---

# SCP Download Command

Return a command sequence that the user can run on their local machine to
download the requested file or files from the current remote server.

- Resolve task references such as "files used for X" from the conversation and
  files actually used for that task. Ask which files when the selection is
  materially ambiguous.
- Verify that every selected source is a regular file on the current remote
  server and resolve it to its full absolute path.
- Use a concrete SSH username, reachable host or alias, and port. Prefer
  connection details already supplied by the user or available from the
  current SSH session. If a copy-paste-ready endpoint cannot be determined,
  ask for the reachable SSH host or alias instead of emitting a placeholder.
- Print one copy-paste-ready command sequence in a `bash` code block, with no
  surrounding prose.
- Start every physical line with `scp`. Add `-P <port>` only for a known
  non-default port that is not covered by an SSH alias.
- Shell-quote each complete remote source operand in the form
  `user@host:/absolute/path` and provide an explicit local destination operand.
- For multiple files, emit one `scp` invocation per file. Join invocations with
  `&& \\` followed by a newline so a failure stops the sequence and pasted
  newlines do not split it into unrelated shell commands.
- Give every file a unique local filename. Derive concise names from the
  distinguishing source path components when unambiguous; for example,
  `A1/trial1/prd10.gro` becomes `A1_trial1.gro`. Ask only when a safe unique
  naming scheme cannot be inferred.
- Never create, rename, copy, or hard-link remote files merely to prepare the
  download command.
- Do not prepend `mkdir`, `cd`, or `ssh`; do not use variables, `~`, globs,
  command substitutions, or placeholders.
- Only display the command. Do not execute `scp`.
