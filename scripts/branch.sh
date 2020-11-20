#!/usr/bin/env bash

fit::branch() {
  local mode
  mode="branch"
  [[ $1 == "--switch" ]] && mode="switch" && shift
  [[ $1 == "--merge" ]] && mode="merge" && shift
  [[ $1 == "--rebase" ]] && mode="rebase" && shift

  # 引数がある場合は git branch を実行して終了
  [[ $# -ne 0 ]] && git branch "$@" && return

  local header
  header="header

  ENTER TO switch branch

"

  local branches branch
  branches="fit core::branch"
  branch=$(
    eval "$branches" |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --no-multi \
        --cycle \
        --border=rounded \
        --preview "fit branch::preview {1}"
  )

  if [[ $? == 0 ]]; then
    branch=$(echo "$branch" | awk '{ print $1 }')
    ! fit::core::branch::is-valid-branch "$branch" && echo "Please select branch name." && return

    if [[ $mode == "switch" ]]; then
      fit::branch::switch "$branch"

    elif [[ $mode == "merge" ]]; then
      fit::branch::merge "$branch"

    elif [[ $mode == "rebase" ]]; then
      fit::branch::rebase "$branch"
    fi
  fi

  git branch -vv && return
}

fit::branch::preview() {
  ! fit::core::branch::is-valid-branch "$1" && return

  git log --graph --oneline --decorate --color=always "$1"
}

fit::branch::switch() {
  local branch
  branch="$1"

  if fit::core::branch::is-remote-branch "$branch"; then
    git switch -t "$branch"
  else
    git switch "$branch"
  fi
}

fit::branch::merge() {
  local branch
  branch="$1"

  eval "git merge $branch $FIT_MERGE_OPTION"
}

fit::branch::rebase() {
  local branch
  branch="$1"

  eval "git rebase $branch $FIT_REBASE_OPTION"
}
