#!/usr/bin/env bash

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
