#!/usr/bin/env bash

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::branch() {
  local locals remotes
  locals=$(git branch --color -vv | sed -e 's/\(^\* \|^  \)//g')
  remotes=$(git branch --color -vv -r | sed -e 's/\(^\* \|^  \)//g')

  if [[ -n $locals ]]; then
    echo "${UNDERLINE}Local branches:${NORMAL}"
    echo "${locals}"
    [[ -n $remotes ]] && echo
  fi

  if [[ -n $remotes ]]; then
    echo "${UNDERLINE}Remotes branches:${NORMAL}"
    echo "${remotes}"
  fi

}

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::branch::is-remote-branch() {
  git branch -r | grep -qE "\s*$1$"
}
