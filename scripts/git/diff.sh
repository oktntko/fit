#!/usr/bin/env bash

# git diff [<options>] [<commit>] [--] [<path>…​]
# git diff [<options>] --cached [<commit>] [--] [<path>…​]
# git diff [<options>] <commit> [<commit>…​] <commit> [--] [<path>…​]
# git diff [<options>] <commit>…​<commit> [--] [<path>…​]
# git diff [<options>] <blob> <blob>
# git diff [<options>] --no-index [--] <path> <path>

fit::core::diff() {
  local -A commits
  commits=(
    ["old"]=""
    ["new"]=""
  )

  local -a options pathes
  options=()
  pathes=()

  local cached no_index is_path

  for x in "$@"; do
    if [[ ${x} == -- ]]; then
      is_path=true # [--]区切り文字 以降はすべて path

    elif [[ ${x} == --cached || ${x} == --staged ]]; then
      cached="--cached" # cachedは特別扱い

    elif [[ ${x} == --no-index ]]; then
      no_index="--no-index" # no-indexは特別扱い

    elif [[ ${x} =~ -.* ]]; then
      # options
      options=("${options[*]}" "${x}")

    else
      # commit or path
      if [[ "${is_path}" || -f ${x} ]]; then
        pathes=("${pathes[*]}" "${x}")
        is_path=true
      else
        commits["old"]="${commits["new"]}"
        commits["new"]="${x}"
      fi
    fi
  done

  # 引数がある場合は git を呼び出して終了
  [[ ${#options[*]} -gt 0 ]] && git diff "$@" && return

  # コマンドを生成
  local git_diff git_diff_preview
  git_diff=$(echo "git diff --stat --color=always ${cached} ${no_index} ${commits[*]} $([[ ${#pathes[*]} -gt 0 ]] && echo "--") ${pathes[*]}" | sed -e 's/ \+/ /g')
  git_diff_preview=$(echo "git diff ${cached} ${no_index} ${commits[*]} --" | sed -e 's/ \+/ /g')
  git_difftool=$(echo "git difftool ${cached} ${no_index} ${commits[*]} --" | sed -e 's/ \+/ /g')

  local header
  header="${GRAY}*${NORMAL} ${WHITE}KeyBindings${NORMAL}                           ${GRAY}*${NORMAL} ${WHITE}Change Options${NORMAL}
| ${WHITE}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} diff                     | Ctrl+${WHITE}H${NORMAL} ❯ ${GREEN}fit${NORMAL} diff --cached
| Ctrl+${WHITE}F${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} difftool (multiselect)   |
| Ctrl+${WHITE}S${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} status                   |

"

  # less -R を入れないとすぐに終了する
  eval "${git_diff}" | sed -e '$d' |
    fit::fzf \
      --header "${header}" \
      --preview "eval ${git_diff_preview} {1} | eval ${FIT_PAGER_DIFF}" \
      --bind "enter:execute(eval ${git_diff_preview} {1} | eval ${FIT_PAGER_DIFF} | less -R > /dev/tty)" \
      --bind "ctrl-s:execute(fit status)+reload(eval ${git_diff} | sed -e '\$d')" \
      --bind "ctrl-f:execute(fit ${git_difftool} {1})" \
      --bind "ctrl-h:abort+execute(fit diff --cached)"
}
