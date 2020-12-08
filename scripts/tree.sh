#!/usr/bin/env bash

fit::tree() {
  local parent
  parent="$1"
  [[ -z ${parent} ]] && parent="."

  echo "${parent}" >log.log

  eval "${FIT_TREE_VIEWER} ${parent}" |
    fit::fzf \
      --header "${parent}/" \
      --preview-window=80% \
      --preview "fit tree::preview ${parent} {}" \
      --bind "enter:execute(fit tree::actions::enter ${parent} {})" \
      --bind "ctrl-d:execute(fit tree::actions::delete ${parent} {})"
}

fit::tree::preview() {
  local parent selected
  parent="$1"
  selected="$2"

  if [[ -d "${parent}/${selected}" ]]; then
    eval "${FIT_PREVIEW_DIRECTORY} ${parent}/${selected}"
  else
    eval "${FIT_PREVIEW_FILE} ${parent}/${selected}"
  fi
}

fit::tree::actions::enter() {
  local parent selected
  parent="$1"
  selected="$2"

  if [[ -d "${parent}/${selected}" ]]; then
    eval "fit::tree ${parent}/${selected}"
  else
    eval "${FIT_EDITOR} ${parent}/${selected} </dev/tty >/dev/tty"
  fi
}

fit::tree::actions::delete() {
  local parent selected
  parent="$1"
  selected="$2"

  # 削除してもいいですか？
  if ! fit::utils::confirm-message "${RED}remove${NORMAL} ${parent}/${selected}?"; then
    return
  fi

  # TODO: 削除できない
  if [[ -d "${parent}/${selected}" ]]; then
    rm -rf "${parent}/${selected}"
  else
    rm "${parent}/${selected}"
  fi
}
