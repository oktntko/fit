#!/usr/bin/env bash

# git diff [<options>] [<commit>] [--] [<path>…​]
# git diff [<options>] --cached [<commit>] [--] [<path>…​]
# git diff [<options>] <commit> [<commit>…​] <commit> [--] [<path>…​]
# git diff [<options>] <commit>…​<commit> [--] [<path>…​]
# git diff [<options>] <blob> <blob>
# git diff [<options>] --no-index [--] <path> <path>

fit::core::diff() {
  local -a options pathes
  options=()
  pathes=()
  local -A commits
  commits=(
    ["old"]=""
    ["new"]=""
  )

  while (($# > 0)); do
    # この二つは特別扱い
    if [[ $1 == --cached || $1 == --staged ]]; then
      cached="--cached"
    elif [[ $1 == --no-index ]]; then
      no_index="--no-index"
    fi

    if [[ $1 == -- ]]; then
      # [--]区切り文字 以降はすべて path
      is_path=true
    elif [[ $1 =~ -.* ]]; then
      # options
      options=("${options[*]}" "$1")
    else
      # commit or path
      if [[ "${is_path}" || -f ${1} ]]; then
        pathes=("${pathes[*]}" "$1")
        is_path=true
      else
        commits["old"]=${commits["new"]}
        commits["new"]="$1"
      fi
    fi

    shift
  done

  # コマンドを生成
  local git_diff git_diff_preview
  git_diff=$(echo "git diff --name-only ${cached} ${no_index} ${commits[*]} $([[ ${#pathes[*]} -gt 0 ]] && echo "--") ${pathes[*]}" | sed -e 's/ \+/ /g')
  git_diff_preview=$(echo "git diff ${cached} ${no_index} ${commits[*]} --" | sed -e 's/ \+/ /g')

  local header
  header="🔹KeyBindings🔹

${GREEN}❯ ${git_diff}${NORMAL}

"

  # less -R を入れないとすぐに終了する
  eval "${git_diff}" |
    fzf \
      --ansi \
      --header "$header" \
      --layout=reverse \
      --border=rounded \
      --no-mouse \
      --multi \
      --cycle \
      --preview "eval $git_diff_preview {} | eval ${FIT_PAGER_DIFF}" \
      --bind "alt-r:toggle-preview" \
      --bind "alt-d:execute(eval $git_diff_preview {} | eval ${FIT_PAGER_DIFF} | less -R)"
}
