#!/usr/bin/env bash

fit::rebase() {
  # 引数がある場合は git rebase を実行して終了
  [[ $# -ne 0 ]] && git rebase "$@" && return

  fit branch --rebase "$@"
}
