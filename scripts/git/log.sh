#!/usr/bin/env bash

# git log [<options>] [<revision range>] [[--] <path>…​]

fit::log::fzf() {
  local preview_window_hidden

  for x in "$@"; do
    if [[ ${x} =~ -.* ]]; then
      # オプションがあったらプレビューは非表示
      preview_window_hidden="--preview-window=:hidden"
      break
    fi
  done

  local header
  header="🔹KeyBindings🔹
  ${BLUE}${S_UNDERLINE}ENTER${NORMAL} ${CYAN}❯ git show${NORMAL}

"
  # オプションがあったら header も非表示。 普通に git log | fzf したときと同じ
  [[ -n ${preview_window_hidden} ]] && header=""

  local fit_fzf
  fit_fzf="fit::fzf \\
    --header \"$header\" \\
    --multi \\
    --preview \"fit log::preview {}\" \\
    --bind \"ctrl-d:execute(fit log::actions::call-diff {+})\" \\
    --bind \"enter:execute(fit log::actions::call-show {} | eval ${FIT_PAGER_SHOW} | less -R)\" \\
    ${preview_window_hidden}
"

  if [[ -n ${preview_window_hidden} ]]; then fit::git log "$@"; else _fit::log::format "$@"; fi | eval "$fit_fzf"

  [[ -z ${preview_window_hidden} ]] && _fit::log::format "$@" -10 && return
}

fit::log::preview() {
  local commit
  commit=$(_fit::log::extract "$@")
  [[ -z ${commit} ]] && return

  echo "${CYAN}❯ git diff ${commit}^ ${commit}${NORMAL}"
  echo
  fit::git diff "${commit}"^ "${commit}" --stat --color=always
  echo
  echo "${CYAN}❯ git show ${commit}${NORMAL}"
  echo
  git show "${commit}" --decorate --color=always | eval "${FIT_PAGER_SHOW}"
}

fit::log::actions::call-diff() {
  local extracts
  extracts=$(_fit::log::extract "$@" | awk -v 'ORS= ' '{print $1}')
  [[ -z ${extracts} ]] && return

  local -A commits
  commits=(
    ["old"]=""
    ["new"]=""
  )

  for x in ${extracts}; do
    commits["old"]="${commits["new"]}"
    commits["new"]="${x}"
  done

  fit::diff "${commits[*]}"
}

fit::log::actions::call-show() {
  local commit
  commit=$(_fit::log::extract "$@")
  [[ -z ${commit} ]] && return

  fit::git show "${commit}"
}

_fit::log::format() {
  git log \
    --graph \
    --color=always \
    --pretty="[%C(yellow)%h%Creset]%C(auto)%d%Creset %s %C(dim)%an%Creset (%C(blue)%ad%Creset)" \
    --date=format:"%Y-%m-%d" \
    "$@"
}

_fit::log::extract() {
  echo "$@" | grep -Eo '\[[a-f0-9]{7}\]' | sed -e 's/\W//g' | uniq
}
