#!/usr/bin/env bash

fit::commit() {
  local header
  header='🔹KeyBindings🔹
  ctrl + s   git add/restore       | 👆stage/👇unstage selected file.

  ctrl + u   git add -u, --update  | update index tracked files.
  ctrl + a   git add -A, --all     | update index all files.
  ctrl + p   git a/r -p, --patch   | stage by line not by file.

🔸Operation fzf🔸
  tab => toggle / alt + a => toggle-all

'

  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  local reload files
  reload="reload(fit status::list)"
  files=$(
    fit status::list |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --multi \
        --cycle \
        --border=rounded \
        --preview "fit status::preview {1} {2..}" \
        --bind "ctrl-s:execute-silent(fit status::change {2..})+$reload" \
        --bind "ctrl-u:execute-silent(fit add-u)+$reload" \
        --bind "ctrl-a:execute-silent(fit add-a)+$reload" \
        --bind "ctrl-p:execute(fit status::patch {2..})+$reload" \
        --bind "alt-a:toggle-all"
  )

  if [[ $? == 0 ]]; then
    git commit "$@" && return
  else
    fit status::list && return
  fi
}
