#!/usr/bin/env bash

fit::log() {
  local header
  header='🔹KeyBindings🔹
  ctrl + s   git add/restore       | 👆stage/👇unstage selected file.

  ctrl + u   git add -u, --update  | update index tracked files.
  ctrl + a   git add -A, --all     | update index all files.
  ctrl + p   git a/r -p, --patch   | stage by line not by file.

🔸Operation fzf🔸
  tab => toggle / alt + a => toggle-all

'

  local reload
  reload="reload(fit log::list)"
  files=$(
    fit log::list |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --border=rounded \
        --preview "fit log::list::extract {} | xargs fit log::preview" \
  )
}

fit::log::list() {
  git log --graph --oneline --decorate --color=always
}

fit::log::list::extract() {
  echo "$@" | grep -Eo '[a-f0-9]+' | head -1
}

fit::log::preview() {
  [[ -n $1 ]] && git show "$1" --decorate --color=always
}
