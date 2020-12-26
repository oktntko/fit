#!/usr/bin/env bash

fit::stash::fzf() {
  local header
  header="${GRAY}*${NORMAL} ${WHITE}KeyBindings${NORMAL}
| ${WHITE}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯${NORMAL} git stash ${GREEN}show${NORMAL}
| Ctrl+${WHITE}A${NORMAL} ${WHITE}❯${NORMAL} git stash ${GREEN}apply${NORMAL}
| Ctrl+${WHITE}P${NORMAL} ${WHITE}❯${NORMAL} git stash ${GREEN}pop${NORMAL}
| Ctrl+${WHITE}D${NORMAL} ${WHITE}❯${NORMAL} git stash ${GREEN}drop${NORMAL}
| Ctrl+${WHITE}R${NORMAL} ${WHITE}❯${NORMAL} git stash ${GREEN}clear${NORMAL}

"
  local fit_fzf
  fit_fzf="fit::fzf \\
        --header \"$header\" \\
        --preview \"fit stash::preview {1}\" \\
        --bind \"enter:execute(fit stash::actions::enter {1})+reload(fit stash::menu)\" \\
        --bind \"ctrl-a:execute(fit stash::actions::call-git-stash-apply {1})+reload(fit stash::menu)\" \\
        --bind \"ctrl-p:execute-silent(fit stash::actions::call-git-stash-pop {1})+reload(fit stash::menu)\" \\
        --bind \"ctrl-d:execute-silent(fit stash::actions::call-git-stash-drop {1})+reload(fit stash::menu)\" \\
        --bind \"ctrl-r:execute-silent(fit stash::actions::call-git-stash-clear)+reload(fit stash::menu)\" \\
        "

  fit::stash::menu | eval "${fit_fzf}"
}

fit::stash::menu() {
  local stashes
  stashes=$(git stash list)

  if fit::utils::has-changed-files; then
    echo "${GRAY}*${NORMAL} ${GREEN}Save changed files${NORMAL}"
    echo "save/push"
    [[ -n $stashes ]] && echo
  fi

  if [[ -n $stashes ]]; then
    echo "${GRAY}*${NORMAL} ${YELLOW}List the stash entries${NORMAL}"
    echo "$stashes"
  fi

  if [[ -n $(fit utils::has-changed-files) && -n $stashes ]]; then
    echo "${RED}You can not do anything stash${NORMAL}"
  fi
}

fit::stash::preview() {
  local stash
  stash="$1"

  if [[ $stash == "save/push" ]]; then # save の場合はstashの対象になるstatusを表示する
    fit status-all

  elif [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    git stash show -p "$stash" | eval "${FIT_PAGER_DIFF}"
  fi
}

fit::stash::actions::enter() {
  local stash
  stash="$1"

  if [[ $stash == "save/push" ]]; then # save の場合はstashの対象になるstatusを表示する
    fit::stash::actions::call-git-stash-save

  elif [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    fit::stash::actions::call-git-stash-show "$stash"
  fi
}

fit::stash::actions::call-git-stash-save() {
  local opt
  fit::utils::input-char opt "Input stash option ${GREEN}u${NORMAL}(--include-untracked) ${GREEN}k${NORMAL}(--keep-index)]"
  if [[ $opt =~ u|U ]]; then
    opt="--include-untracked"
  elif [[ $opt =~ k|K ]]; then
    opt="--keep-index"
  else
    opt=""
  fi

  local message
  fit::utils::input-text message "Input stash ${GREEN}message${NORMAL}"

  eval "git stash save ${opt} \"${message}\""
}

fit::stash::actions::call-git-stash-show() {
  local stash
  stash="$1"

  git stash show -p "$stash" | eval "${FIT_PAGER_DIFF}" | less -R >/dev/tty
}

fit::stash::actions::call-git-stash-apply() {
  local stash
  stash="$1"

  if [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    git stash apply "$stash"
  fi
}

fit::stash::actions::call-git-stash-pop() {
  local stash
  stash="$1"

  if [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    git stash pop "$stash"
  fi
}

fit::stash::actions::call-git-stash-drop() {
  local stash
  stash="$1"

  if [[ $stash =~ :$ ]]; then
    stash="${stash%:}"

    git stash drop "$stash"
  fi
}

fit::stash::actions::call-git-stash-clear() {
  git stash clear
}
