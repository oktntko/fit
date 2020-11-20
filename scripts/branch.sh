#!/usr/bin/env bash

fit::branch() {
  # 引数がある場合は git branch を実行して終了
  [[ $# -ne 0 ]] && git branch "$@" && return

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
    [[ -n "$branch" ]] && echo "$branch" | awk -v 'ORS= ' '{ print $1 }' | xargs fit branch::switch
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
