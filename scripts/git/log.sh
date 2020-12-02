#!/usr/bin/env bash

# git log [<options>] [<revision range>] [[--] <path>…​]

fit::log::fzf() {
  local header
  header="${B_GREEN} ${NORMAL} ${S_UNDERLINE}${WHITE}KeyBindings${NORMAL}
  ${CYAN}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯ git show${NORMAL}
  ${CYAN}ctrl+F${NORMAL} ${WHITE}❯ git difftool${NORMAL} (multiselect)
  ${CYAN}ctrl+D${NORMAL} ${WHITE}❯ ${GREEN}fit${WHITE} diff${NORMAL} (multiselect)

"

  local -a options branches pathes
  options=()
  branches=()
  pathes=()

  local all_branches tags remotes is_path preview_window_hidden

  # TODO: オプションの選別
  for x in "$@"; do
    if [[ ${x} == -- ]]; then
      is_path=true # [--]区切り文字 以降はすべて path
    elif [[ ${x} == --oneline || ${x} == --decorate || ${x} == --graph ]]; then
      : # --oneline --decorate --graph は無視

    elif [[ ${x} == --branches ]]; then
      all_branches="--branches" # branchesは特別扱い

    elif [[ ${x} == --tags ]]; then
      tags="--tags" # tagsは特別扱い

    elif [[ ${x} == --remotes ]]; then
      remotes="--remotes" # remotesは特別扱い

    elif [[ ${x} =~ -.* ]]; then
      # options
      options=("${options[*]}" "${x}")

      # オプションがあったらプレビューは非表示
      preview_window_hidden="--preview-window=:hidden"
      # オプションがあったら header も非表示。 普通に git log | fzf したときと同じ
      header=""

    else
      # commit or path
      if [[ "${is_path}" || -f ${x} ]]; then
        pathes=("${pathes[*]}" "${x}")
        is_path=true
      else
        branches=("${branches[*]}" "${x}")
      fi
    fi
  done

  # コマンドを生成
  local git_log
  if [[ ${#options[*]} -gt 0 ]]; then
    git_log="fit git log \"$*\""
  else
    git_log="git log \\
      --graph \\
      --color=always \\
      --pretty=\"[%C(yellow)%h%Creset]%C(auto)%d%Creset %s %C(dim)%an%Creset (%C(blue)%ad%Creset)\" \\
      --date=format:\"%Y-%m-%d\" \\
      ${all_branches} \\
      ${tags} \\
      ${remotes} \\
      $([[ ${#pathes[*]} -gt 0 ]] && echo "--") ${pathes[*]}"
  fi

  local fit_fzf
  fit_fzf="fit::fzf \\
    --header \"$header\" \\
    --multi \\
    --preview \"fit log::preview {}\" \\
    --bind \"ctrl-d:execute(fit log::actions::call-fit-diff {+})\" \\
    --bind \"ctrl-f:execute(fit log::actions::call-git-difftool {+})\" \\
    --bind \"enter:execute(fit log::actions::call-git-show {} | eval ${FIT_PAGER_SHOW} | less -R)\" \\
    ${preview_window_hidden} \\
"

  eval "${git_log}" | eval "${fit_fzf}"
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

# /*
# call fit diff.
# @param string[] commits. last selected is first element[0]. first selected is last element[-1].
# */
fit::log::actions::call-fit-diff() {
  local -a commits
  mapfile -t commits < <(_fit::log::extract "$@")
  [[ ${#commits[*]} -le 0 ]] && return

  # $()をダブルクォーテーションでくくると空文字がパラメータになるのでくくらない
  # shellcheck disable=2046
  fit::diff "${commits[0]}" $([[ ${#commits[*]} -gt 1 ]] && echo "${commits[-1]}")
}

# /*
# call git difftool.
# @param string[] commits. last selected is first element[0]. first selected is last element[-1].
# */
fit::log::actions::call-git-difftool() {
  local -a commits
  mapfile -t commits < <(_fit::log::extract "$@")
  [[ ${#commits[*]} -le 0 ]] && return

  # [-1]が最後の要素を示すらしい
  # shellcheck disable=2046
  fit::git difftool "${commits[0]}" $([[ ${#commits[*]} -gt 1 ]] && echo "${commits[-1]}")
}

fit::log::actions::call-git-show() {
  local commit
  commit=$(_fit::log::extract "$@")
  [[ -z ${commit} ]] && return

  fit::git show "${commit}"
}

_fit::log::extract() {
  echo "$@" | grep -Eo '\[[a-f0-9]{7}\]' | sed -e 's/\W//g'
}
