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
        --preview \"fit stash::preview {1}\" \\
        "

  fit::stash::menu | eval "${fit_fzf}"
}

fit::stash::menu() {
  if fit::utils::has-changed-files; then
    echo "${GREEN}Save changed files${NORMAL}"
    echo "save"
  fi

  local stashes
  stashes=$(git stash list)
  if [[ -n $stashes ]]; then
    echo
    echo "${YELLOW}List the stash entries${NORMAL}"
    echo "$stashes"
  fi

  if [[ -n $(fit utils::has-changed-files) && -n $stashes ]]; then
    echo "${RED}You can not do anything${NORMAL}"
  fi
}

fit::stash::preview() {
  local stash
  stash="$1"

  if [[ $stash == "save" ]]; then
    fit status-all

  elif [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    git stash show -p "$stash" | eval "${FIT_PAGER_DIFF}"
  fi
}

# Git stash save
# Git stash list
# Git stash apply
# Git stash pop
# Git stash show
# Git stash branch <name>
# Git stash clear
# Git stash drop
