#!/usr/bin/env bash

fit::branch() {
  local mode
  mode="branch"
  [[ $1 == "--switch" || $1 == "-s" ]] && mode="switch" && shift
  [[ $1 == "--merge" || $1 == "-m" ]] && mode="merge" && shift
  [[ $1 == "--rebase" || $1 == "-r" ]] && mode="rebase" && shift

  local header
  header="header

  ENTER TO swtich branch

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
    if [[ $mode == "switch" ]]; then
      [[ -n "$branch" ]] && echo "$branch" | awk '{ print $1 }' | xargs fit branch::switch

    elif [[ $mode == "merge" ]]; then
      [[ -n "$branch" ]] && echo "$branch" | awk '{ print $1 }' | xargs fit branch::switch

    elif [[ $mode == "rebase" ]]; then
      [[ -n "$branch" ]] && echo "$branch" | awk '{ print $1 }' | xargs fit branch::switch
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
  branch=$1

  ! fit::core::branch::is-valid-branch "$1" && echo "Please select branch name." && return

  if fit::core::branch::is-remote-branch "$branch"; then
    git switch -t "$branch"
  else
    git switch "$branch"
  fi
}
