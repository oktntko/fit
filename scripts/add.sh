#!/usr/bin/env bash

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && return

  fit status --add
}

fit::add-u() {
  git add -u
}

fit::add-a() {
  git add -A
}
