#!/usr/bin/env bash

# restore --staged             => stage状態を取り消す. stage/unstage
# restore --worktree(default)  => 変更を取り消す. checkout/reset --hard

fit::restore() {
  # 引数がある場合は git restore を実行して終了
  [[ $# -ne 0 ]] && git restore "$@" && return

  fit status --restore
}

# /*
# 引数のファイルの変更を取り消す
# @param string[] files.
# */
fit::restore::worktree() {
  # TODO: ファイルがstaging 状態だと利かない
  for file in "$@"; do
    git restore --worktree "$file"
  done
}
