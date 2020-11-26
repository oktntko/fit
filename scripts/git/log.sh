#!/usr/bin/env bash

# git log [<options>] [<revision range>] [[--] <path>…​]

fit::core::log() {

  # for x in "$@"; do
  #   # オプションがあったらプレビューは非表示
  # done

  local header
  header="🔹KeyBindings🔹
  Ctrl+D select two commit and Ctrl+D then git diff.

"

  local fit_fzf
  fit_fzf="fit::fzf \\
    --header \"$header\" \\
    --multi \\
    --preview \"fit core::log::extract {} | xargs fit log::preview\" \\
    --bind \"ctrl-d:execute(fit core::log::extract {} {+} | xargs fit log::diff)\" \\
"
  # optionがある時は --preview-window=:hidden

  fit::core::log::format "$@" | eval "$fit_fzf"

  fit::core::log::format -10 "$@" && return
}

fit::log::preview() {
  [[ -z $1 ]] && return
  echo "${CYAN}❯ git diff $1^ $1${NORMAL} --stat --color=always"
  echo
  git diff "$1"^ "$1" --stat --color=always
  echo
  echo "${CYAN}❯ git show $1${NORMAL} --decorate --color=always"
  echo
  git show "$1" --decorate --color=always | eval "${FIT_PAGER_SHOW}"
}

fit::log::diff() {
  # 引数パターン
  # 引数なし     => ありえない(現在の行)
  # 引数１個     => フォーカス行                            => git diff フォーカス行と最新の行の比較
  # 引数２個     => フォーカス行 選択行                     => git diff フォーカス行と選択行の比較
  # 引数３個     => フォーカス行 選択行１ 選択行２          => git diff 選択行１と選択行２の比較
  # 引数３個以上 => フォーカス行 選択行１ 選択行２ 選択行３ => git diff 選択行２と選択行３の比較
  local -a array=("HEAD")
  local opt
  for opt in "$@"; do
    if [[ ${#array[@]} -ge 2 ]]; then
      array=("${array[@]:0:${#array[@]}-1}")
    fi
    array=("$opt" "${array[@]}")
    shift
  done

  fit::diff "${array[0]}" "${array[1]}"
}

fit::core::log::format() {
  git log \
    --graph \
    --color=always \
    --pretty="[%C(yellow)%h%Creset]%C(auto)%d%Creset %s %C(dim)%an%Creset (%C(blue)%ad%Creset)" \
    --date=format:"%Y-%m-%d" \
    "$@"
}

fit::core::log::extract() {
  echo "$@" | grep -Eo '\[[a-f0-9]{7}\]' | sed -e 's/\W//g' | uniq
}

fit::log::list::extract() {
  echo "$@" | grep -Eo '[a-f0-9]+' | head -1
}
