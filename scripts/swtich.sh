#!/usr/bin/env bash

fit::swtich() {
  # 引数がある場合は git swtich を実行して終了
  [[ $# -ne 0 ]] && git swtich "$@" && return

  fit branch --swtich "$@"
}
