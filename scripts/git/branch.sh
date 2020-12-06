#!/usr/bin/env bash

# git branch [--color[=<when>] | --no-color] [--show-current]
# 	[-v [--abbrev=<length> | --no-abbrev]]
# 	[--column[=<options>] | --no-column] [--sort=<key>]
# 	[--merged [<commit>]] [--no-merged [<commit>]]
# 	[--contains [<commit>]] [--no-contains [<commit>]]
# 	[--points-at <object>] [--format=<format>]
# 	[(-r | --remotes) | (-a | --all)]
# 	[--list] [<pattern>…​]
# git branch [--track | --no-track] [-f] <branchname> [<start-point>]
# git branch (--set-upstream-to=<upstream> | -u <upstream>) [<branchname>]
# git branch --unset-upstream [<branchname>]
# git branch (-m | -M) [<oldbranch>] <newbranch>
# git branch (-c | -C) [<oldbranch>] <newbranch>
# git branch (-d | -D) [-r] <branchname>…​
# git branch --edit-description [<branchname>]

fit::branch::fzf() {
  local mode
  mode="branch"
  [[ $1 == "--switch" ]] && mode="switch" && shift
  [[ $1 == "--merge" ]] && mode="merge" && shift
  [[ $1 == "--rebase" ]] && mode="rebase" && shift

  # 引数がある場合は git branch を実行して終了
  [[ $# -ne 0 ]] && git branch "$@" && return

  local header
  header="* KeyBindings                           * Change Options
| ENTER   git ${mode} [branch]         | Ctrl+S ❯ fit switch
| Ctrl+N  git branch -m                | Ctrl+R ❯ fit merge
| Ctrl+D  fit branch -D (force)        | Ctrl+B ❯ fit rebase
| Ctrl+L  fit log (multiselect)

"

  # コマンドを生成
  local git_branch fit_fzf
  git_branch="fit branch::branch-list"
  fit_fzf="fit::fzf \\
        --header \"$header\" \\
        --preview \"fit branch::preview {1}\" \\
        --bind \"ctrl-n:execute(fit branch::actions::call-git-branch-rename {1})+reload(eval $git_branch)\" \\
        --bind \"ctrl-d:execute(fit branch::actions::call-git-branch-delete {1})+reload(eval $git_branch)\" \\
  "

  local branch
  branch=$(eval "${git_branch}" | eval "${fit_fzf}")

  if [[ $? == 0 ]]; then
    branch=$(echo "$branch" | awk '{ print $1 }')
    ! fit::utils::is-valid-branch "$branch" && echo "Please select branch name." && return

    if [[ $mode == "switch" ]]; then
      fit::branch::switch "$branch"

    elif [[ $mode == "merge" ]]; then
      fit::branch::merge "$branch"

    elif [[ $mode == "rebase" ]]; then
      fit::branch::rebase "$branch"
    fi
  fi
}

fit::branch::branch-list() {
  local locals remotes
  locals=$(fit git branch -vv | sed -e 's/\(^\* \|^  \)//g')
  remotes=$(fit git branch -vv -r | sed -e 's/\(^\* \|^  \)//g')

  if [[ -n $locals ]]; then
    echo "${S_UNDERLINE}Local branches:${NORMAL}"
    echo "${locals}"
    [[ -n ${remotes} ]] && echo
  fi

  if [[ -n ${remotes} ]]; then
    echo "${S_UNDERLINE}Remotes branches:${NORMAL}"
    echo "${remotes}"
  fi
}

fit::branch::preview() {
  ! fit::utils::is-valid-branch "$1" && return

  git log --graph --oneline --decorate --color=always "$1"
}

fit::branch::actions::call-git-branch-rename() {
  # fzf execute で標準入力＋出力を行う例
  # vim とかadd -p とかと同じように 入力 </dev/tty 出力 >/dev/tty が必要
  # TODO: 色の意味を考えないと
  local branch
  branch="$1"

  if ! fit::utils::is-valid-branch "$branch" || fit::utils::is-remote-branch "$branch"; then
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

fit::branch::actions::call-git-branch-delete() {
  local branch
  branch="$1"

  if ! fit::utils::is-valid-branch "$branch"; then
    # 不正なブランチ名の場合
    fit::utils::error-message "${RED}Please select branch name.${NORMAL}"
    return
  fi

  # 削除なので確認しておく
  if ! fit::utils::confirm-message "${RED}Delete${NORMAL} '${branch}' branch? [y/N] ${GREEN}❯${NORMAL} "; then
    return
  fi

  if fit::utils::is-remote-branch "$branch"; then
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

fit::branch::actions::call-git-switch() {
  local branch
  branch="$1"

  if fit::utils::is-remote-branch "$branch"; then
    git switch -t "$branch"
  else
    git switch "$branch"
  fi
}

fit::branch::actions::call-git-merge() {
  local branch
  branch="$1"

  eval "git merge $branch $FIT_MERGE_OPTION"
}

fit::branch::actions::call-git-rebase() {
  local branch
  branch="$1"

  eval "git rebase $branch $FIT_REBASE_OPTION"
}
