#!/usr/bin/env bash

fit::switch() {
  # 引数がある場合は git switch を実行して終了
  [[ $# -ne 0 ]] && git switch "$@" && return

  fit branch --switch "$@"
}
