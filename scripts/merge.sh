#!/usr/bin/env bash

fit::merge() {
  # 引数がある場合は git merge を実行して終了
  [[ $# -ne 0 ]] && git merge "$@" && return

  fit branch --merge "$@"
}
