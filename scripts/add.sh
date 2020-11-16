#!/usr/bin/env bash

fit::add-u() {
  git add -u
}

fit::add-a() {
  git add -A
}

fit::add-p() {
  local s file
  s=$1
  file=$2

  # エディタを開く場合は </dev/tty >/dev/tty がないと
  # Input is not from a terminal
  # Output is not to a terminal
  # が出て動きが止まる
  git add -p "$file" </dev/tty >/dev/tty
}

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && git status -su && return

  local header
  header='enter to ACCEPT. tab Multi select.

🔹KeyBindings🔹
  ctrl+u     ✔️ -u, --update    Update the index just where it already has an entry matching <pathspec>.
  ctrl+a     ✔️ -A, --all       Update the index not only where the working tree has a file matching <pathspec> but also where the index already has an entry.
  ctrl+p     💬 -p, --patch     Interactively choose hunks of patch between the index and the work tree and add them to the index.

'

  # --------------------------------------------------------------------------------
  #  M fit
  #  M scripts/add.sh
  # ?? memo.txt
  # --------------------------------------------------------------------------------

  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  local files reload
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
        --bind "ctrl-u:execute(fit add-u)+$reload" \
        --bind "ctrl-a:execute(fit add-a)+$reload" \
        --bind "ctrl-p:execute(fit add-p {1} {2..})+$reload"
  )
  [[ -n "$files" ]] && echo "$files" | awk -v 'ORS= ' '{ print $2 }' | xargs git add && fit status::list && return
  # TODO: D ファイルが含まれているとエラー
}
