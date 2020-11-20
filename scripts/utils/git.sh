#!/usr/bin/env bash
fit::utils::is-inside-work-tree() {
  git rev-parse --is-inside-work-tree >/dev/null
}

fit::utils::valid-files() {
  local filter
  filter=$(git ls-files -cdom)

  [[ -z $filter ]] && return

  local grfile
  grfile="grep --color=never "
  while IFS= read -r line; do
    grfile="${grfile} -e ^${line}$"
  done < <(echo "$filter")

  eval "$grfile"
}
