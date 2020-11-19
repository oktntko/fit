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
  # git diff --name-only          => unstaged な変更を表示する
  # git diff --name-only --staged => staged な変更を表示する
  local opt filter
  for opt in "$@"; do
    case $opt in
    --staging-only)
      filter=$(git diff --name-only --staged)
      [[ -z ${filter} ]] && return
      ;;
    --unstaging-only)
      filter=$(git diff --name-only)
      [[ -z ${filter} ]] && return
      ;;
    esac
    shift
  done

  local s
  s=$(git -c color.ui=always -c status.relativePaths=true status -su)

  if [[ -n ${filter} ]]; then
    # filter の指定がある場合、文字列を連結する
    local grfile
    grfile="grep --color=never "
    while IFS= read -r line; do
      grfile="${grfile} -e ${line}"
    done < <(echo "$filter")

    # オプションとして grep の後ろにつけると機能しなかったのでマルっと eval で実行
    s=$(echo "${s}" | eval "${grfile}")
  fi

  echo "$s"
}

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::core::status::is-staging() {
  git diff --name-only --staged | grep -qE ^"$1"$
}
