#!/usr/bin/env bash

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
# @return boolean true: is staging/ false: not staging.
# */
fit::core::status() {
  local statuses
  statuses=$(git -c color.ui=always -c status.relativePaths=true status -su)

  local stating unstaging untracked
  stating=$(echo "${statuses}" | fit core::status::list-files --staging-only)
  unstaging=$(echo "${statuses}" | fit core::status::list-files --unstaging-only)
  untracked=$(echo "${statuses}" | fit core::status::list-files --untracked-only)

  if [[ -n $stating ]]; then
    echo "${GREEN}Changes to be committed:${NORMAL}"
    echo "${stating}"
    [[ -n $unstaging ]] || [[ -n $untracked ]] && echo
  fi

  if [[ -n $unstaging ]]; then
    echo "${RED}Changes not staged for commit:${NORMAL}"
    echo "${unstaging}"
    [[ -n $untracked ]] && echo
  fi

  if [[ -n $untracked ]]; then
    echo "${YELLOW}Untracked files:${NORMAL}"
    echo "${untracked}"
  fi
}

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::status::is-staging() {
  git diff --name-only --staged | grep -qE ^"$1"$
}

fit::core::status::list-files() {
  local filter
  if [[ $1 == --staging-only ]]; then
    # git diff --name-only --staged => staged な変更を表示する
    filter=$(git diff --name-only --staged)
  elif [[ $1 == --unstaging-only ]]; then
    # git diff --name-only          => unstaged な変更を表示する
    filter=$(git diff --name-only)
  elif [[ $1 == --untracked-only ]]; then
    # git ls-files --others --exclude-standard =>
    #    others           : 管理対象外のファイル
    #    exclude-standard : .gitignoreで無視されているファイルを除く
    filter=$(git ls-files --others --exclude-standard)
  fi

  [[ -z $filter ]] && return

  local grfile
  grfile="grep --color=never "
  while IFS= read -r line; do
    grfile="${grfile} -e ${line}"
  done < <(echo "$filter")

  eval "${grfile}"
}
