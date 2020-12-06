#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# filesystem
# --------------------------------------------------------------------------------

fit::utils::edit-file() {
  ! fit::utils::is-valid-file "$1" && return

  eval "${FIT_EDITOR} ${1}  </dev/tty >/dev/tty"
}

fit::utils::remove-file() {
  ! fit::utils::is-valid-file "$1" && return

  rm "$1"
}

# --------------------------------------------------------------------------------
# git
# --------------------------------------------------------------------------------

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

fit::utils::is-valid-file() {
  git ls-files -cdom | grep -qE "^$1$"
}

# /*
# 引数のブランチがリモートブランチかどうか判定する
# @param string branch.
# @return boolean true: is remote/ false: is local.
# */
fit::utils::is-remote-branch() {
  git branch -r --format="%(refname:short)" | grep -qE "^$1$"
}

# /*
# 引数のブランチが存在するブランチかどうか判定する
# @param string branch.
# @return boolean true: is valid/ false: not valid.
# */
fit::utils::is-valid-branch() {
  git branch -a --format="%(refname:short)" | grep -qE "^$1$"
}

# --------------------------------------------------------------------------------
# string
# --------------------------------------------------------------------------------

# quotes mult-word parameters in order to make a command copy-paste with ease
fit::utils::quote-single-param() {
  if [ -z "$1" ] || [[ "$1" = *' '* ]]; then
    if [[ "$1" = *"'"* ]]; then
      echo "\"$1\""
    else
      echo "'$1'"
    fi
  else
    echo "$1"
  fi
}

# quotes a list of params using `"$@"`
# MISSING: support for anything escapable (`\n`, `\t`, etc.?)
# MISSING: support quotes in params (e.g. quoting `'a' "b'd"`)
fit::utils::quote-params() {
  local rest=""
  for arg in "$@"; do
    if [ -z "$rest" ]; then
      printf "%s" "$(fit::utils::quote-single-param "$arg")"
      rest=true
    else
      printf " %s" "$(fit::utils::quote-single-param "$arg")"
    fi
  done
}

fit::utils::random() {
  cat </dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

# --------------------------------------------------------------------------------
# user
# --------------------------------------------------------------------------------

# /*
# 確認用メッセージ
# @param string message.
# @return boolean 0: is yes/ 1: is no.
# */
fit::utils::confirm-message() {
  local yn
  read -p "$* [y/N] ❯ " -r -n 1 -s yn </dev/tty
  echo >/dev/tty
  [[ $yn =~ y|Y ]] && return 0
  [[ ! $yn =~ y|Y ]] && return 1
}

# /*
# エラー通知メッセージ
# @param string message.
# */
fit::utils::error-message() {
  read -p "$* [Press any key] ❯ " -r -n 1 -s </dev/tty
  echo >/dev/tty
}

# /*
# 入力用メッセージ
# @param 特殊. 引数に戻り値を代入する.
# */
fit::utils::input-message() {
  local input
  read -p "${*:2} ❯ " -r input </dev/tty
  eval $1="${input}"
}