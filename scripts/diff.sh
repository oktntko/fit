#!/usr/bin/env bash

fit::diff() {

  local header
  header="🔹KeyBindings🔹

❯ git diff $*
"

  git diff --name-only "$@" |
    fzf \
      --ansi \
      --header "$header" \
      --layout=reverse \
      --border=rounded \
      --no-mouse \
      --multi \
      --preview "git diff $* {} | eval ${FIT_PAGER_DIFF}"
}
