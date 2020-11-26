#!/usr/bin/env bash

fit::branch() {
  local mode
  mode="branch"
  [[ $1 == "--switch" ]] && mode="switch" && shift
  [[ $1 == "--merge" ]] && mode="merge" && shift
  [[ $1 == "--rebase" ]] && mode="rebase" && shift

  # 引数がある場合は git branch を実行して終了
  [[ $# -ne 0 ]] && git branch "$@" && return

  local header
  if [[ $mode != "branch" ]]; then
    header="${YELLOW}ENTER${NORMAL} to ${YELLOW}${mode}${NORMAL} branch
"
  fi
  header="${header}
  Ctrl+N : Rename branch.
  Ctrl+D : Delete branch(force).
  Ctrl+L : Log view.

"

  local branches branch
  branches="fit core::branch"
  branch=$(
    eval "$branches" |
      fit::fzf \
        --header "$header" \
        --preview "fit branch::preview {1}" \
        --bind "ctrl-n:execute(fit branch::rename {1})+reload(eval $branches)" \
        --bind "ctrl-d:execute(fit branch::delete {1})+reload(eval $branches)" \
        --bind "ctrl-l:execute(fit core::log {1})+reload(eval $branches)"
  )

  if [[ $? == 0 ]]; then
    branch=$(echo "$branch" | awk '{ print $1 }')
    ! fit::core::branch::is-valid-branch "$branch" && echo "Please select branch name." && return

    if [[ $mode == "switch" ]]; then
      fit::branch::switch "$branch"

    elif [[ $mode == "merge" ]]; then
      fit::branch::merge "$branch"

    elif [[ $mode == "rebase" ]]; then
      fit::branch::rebase "$branch"
    fi
  fi

  git branch -vv && return
}

fit::branch::preview() {
  ! fit::core::branch::is-valid-branch "$1" && return

  git log --graph --oneline --decorate --color=always "$1"
}

fit::branch::switch() {
  local branch
  branch="$1"

  if fit::core::branch::is-remote-branch "$branch"; then
    git switch -t "$branch"
  else
    git switch "$branch"
  fi
}

fit::branch::merge() {
  local branch
  branch="$1"

  eval "git merge $branch $FIT_MERGE_OPTION"
}

fit::branch::rebase() {
  local branch
  branch="$1"

  eval "git rebase $branch $FIT_REBASE_OPTION"
}

fit::branch::rename() {
  # fzf execute で標準入力＋出力を行う例
  # vim とかadd -p とかと同じように 入力 </dev/tty 出力 >/dev/tty が必要
  # TODO: 色の意味を考えないと
  local branch
  branch="$1"

  if ! fit::core::branch::is-valid-branch "$branch" || fit::core::branch::is-remote-branch "$branch"; then
    # 不正なブランチ名 or リモートブランチの場合
    # 思いつく方法が面倒なのでエラーにする
    read -p "${RED}Please select local branch.${NORMAL} [Press any key] ${GREEN}❯${NORMAL} " -r -n 1 -s </dev/tty
    echo >/dev/tty
    return

  fi

  # ローカルブランチの場合
  echo "${YELLOW}Please input new branch name.${NORMAL}" >/dev/tty
  read -p "git branch -m ${branch} ${GREEN}❯${NORMAL} " -r input </dev/tty
  echo >/dev/tty

  if git check-ref-format --branch "${input}" >/dev/null 2>&1; then
    git branch -m "${branch}" "${input}"
    return

  else
    echo "${RED}'${input}' is not is not a valid branch name${NORMAL}" >/dev/tty
    return

  fi
}

fit::branch::delete() {
  local branch
  branch="$1"

  if ! fit::core::branch::is-valid-branch "$branch"; then
    # 不正なブランチ名の場合
    read -p "${RED}Please select branch name.${NORMAL} [Press any key] ${GREEN}❯${NORMAL} " -r -n 1 -s </dev/tty
    echo >/dev/tty
    return
  fi

  # 削除なので確認しておく
  read -p "Delete '${branch}' branch? [y/N] ${GREEN}❯${NORMAL} " -r -n 1 -s yn </dev/tty
  echo >/dev/tty
  [[ ! $yn =~ y|Y ]] && return

  if fit::core::branch::is-remote-branch "$branch"; then
    # リモートはちょっと面倒
    local remote
    remote=$(git remote | head -1)
    branch=$(echo "${branch}" | sed -e "s/${remote}\///g")

    eval "git push ${remote} --delete ${branch}" >/dev/tty
    # TODO: 処理中なのに入力なので何か止められないか
  else
    git branch -D "$branch"
  fi
}

fit::core::branch() {
  local locals remotes
  locals=$(git branch --color -vv | sed -e 's/\(^\* \|^  \)//g')
  remotes=$(git branch --color -vv -r | sed -e 's/\(^\* \|^  \)//g')

  if [[ -n $locals ]]; then
    echo "${S_UNDERLINE}Local branches:${NORMAL}"
    echo "${locals}"
    [[ -n $remotes ]] && echo
  fi

  if [[ -n $remotes ]]; then
    echo "${S_UNDERLINE}Remotes branches:${NORMAL}"
    echo "${remotes}"
  fi
}

# /*
# 引数のブランチがリモートブランチかどうか判定する
# @param string branch.
# @return boolean true: is remote/ false: is local.
# */
fit::core::branch::is-remote-branch() {
  git branch -r --format="%(refname:short)" | grep -qE "^$1$"
}

# /*
# 引数のブランチが存在するブランチかどうか判定する
# @param string branch.
# @return boolean true: is valid/ false: not valid.
# */
fit::core::branch::is-valid-branch() {
  git branch -a --format="%(refname:short)" | grep -qE "^$1$"
}
