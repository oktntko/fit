#!/usr/bin/env bash
fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && git status -su && return

  local header
  header='
  enter       ACCEPT.
  tab         Multi select.
  ctrl + p    patch

'

  local preview
  preview="
  local s file
  s={1}
  file={2..}
  echo \$s \$file
"

  local add_p
  add_p="
  local s file
  s={1}
  file={2..}
  git add -p \$file < /dev/tty > /dev/tty
"

  local files reload
  reload="reload:git -c color.ui=always -c status.relativePaths=true status -su"
  files=$(git -c color.ui=always -c status.relativePaths=true status -su)
  # --------------------------------------------------------------------------------
  #  M fit
  #  M scripts/add.sh
  # ?? memo.txt
  # --------------------------------------------------------------------------------
  files=$(
    echo "$files" |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --multi \
        --cycle \
        --border=rounded \
        --preview "$preview" \
        --bind "ctrl-p:execute($add_p)+$reload"
  )
  # [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git add % && git status -su && return
}
