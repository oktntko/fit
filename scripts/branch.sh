#!/usr/bin/env bash

fit::branch() {
  # 引数がある場合は git branch を実行して終了
  [[ $# -ne 0 ]] && git branch "$@" && return

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
  eval "$branches" |
    fzf \
      --ansi \
      --header "$header" \
      --layout=reverse \
      --no-multi \
      --cycle \
      --border=rounded \
      --preview "fit branch::preview {1}" \
      --bind "enter:execute(fit branch::execute $mode {1} {q})"

  git branch -vv && return
}

fit::branch::preview() {
  ! fit::core::branch::is-valid-branch "$1" && return

  git log --graph --oneline --decorate --color=always "$1"
}

fit::branch::execute() {
  local mode branch
  mode="$1" && shift
  branch="$1" && shift

  ! fit::core::branch::is-valid-branch "$1" && echo "Please select branch name." && return

  if [[ $mode == "switch" ]]; then
    fit branch::switch "$branch" "$@"

  elif [[ $mode == "merge" ]]; then
    fit branch::merge "$branch" "$@"

  elif [[ $mode == "rebase" ]]; then
    fit branch::rebase "$branch" "$@"
  fi
}

fit::branch::switch() {
  local branch
  branch=$1 && shift

  if fit::core::branch::is-remote-branch "$branch"; then
    git switch -t "$branch" "$@"
  else
    git switch "$branch" "$@"
  fi
}

fit::branch::merge() {
  local branch
  branch=$1 && shift

  git merge "$branch" "$@"
}

fit::branch::rebase() {
  local branch
  branch=$1 && shift

  git rebase "$branch" "$@"
}
