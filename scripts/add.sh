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

  fit status --add
}
