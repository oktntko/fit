#!/usr/bin/env bash

fit::stash::fzf() {
  local header
  header="${GRAY}*${NORMAL} ${WHITE}KeyBindings${NORMAL}                           ${GRAY}*${NORMAL} ${WHITE}Change Options${NORMAL}
| ${WHITE}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} show                     | Ctrl+${WHITE}B${NORMAL} ❯ ${GREEN}fit${NORMAL} log --branches
| Ctrl+${WHITE}F${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} difftool (multiselect)   | Ctrl+${WHITE}R${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} log --remotes
| Ctrl+${WHITE}D${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} diff (multiselect)       | Ctrl+${WHITE}A${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} log --all

"
  local fit_fzf
  fit_fzf="fit::fzf \\
        --header \"$header\" \\
        "

  fit::stash::menu | eval "${fit_fzf}"
}

fit::stash::menu() {
  if fit::utils::has-changed-files; then
    echo "has changed"
  fi

  echo "save"
  echo "list"
  echo "apply"
  echo "pop"
  echo "drop"
  echo "clear"
}
