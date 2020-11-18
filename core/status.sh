#!/usr/bin/env bash

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::status::is-staging() {
  git diff --name-only --cached | grep -qE ^"$1"$
}

# M = modified
# A = added
# D = deleted
# R = renamed
# C = copied
# U = updated but unmerged
# ? = untracked

# /*
# 引数のファイルのindexの状態を判定する
# @option --staging-only
# @option --unstaging-only
# @option --tracked-only
# @option --untracked-only
# @return boolean true: is staging/ false: not staging.
# */
fit::core::status() {
  local opt
  for opt in "$@"; do
    case $opt in
    -a)
      FLAG_A=1
      ;;
    -b)
      FLAG_B=1
      VALUE_B=$2
      shift
      ;;
    esac
    shift
  done

  git -c color.ui=always -c status.relativePaths=true status -su
}
