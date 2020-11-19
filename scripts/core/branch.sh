#!/usr/bin/env bash

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::branch() {
  eval "git branch --color -vv $1" | sed -e 's/\(^\* \|^  \)//g'
}

fit::core::branch::change-target() {
  if [[ $FIT_CORE_BRANCH_MODE == "remotes" ]]; then
    echo "all"
  elif [[ $FIT_CORE_BRANCH_MODE == "all" ]]; then
    echo "local"
  else
    echo "remotes"
  fi
}
