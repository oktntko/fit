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
  mode="branch "
  [[ $1 == "--switch" ]] && mode="switch " && shift
  [[ $1 == "--merge" ]] && mode="merge  " && shift
  [[ $1 == "--rebase" ]] && mode="rebase " && shift

  # TODO: オプションの選別
  local -a options merged no_merged
  for x in "$@"; do
    if [[ ${x} == -v || ${x} == "-a" || ${x} == "--all" || ${x} == "-r" || ${x} == "--remotes" ]]; then
      : # 無視

    elif [[ ${x} == --merged ]]; then
      merged="--merged" # branchesは特別扱い

    elif [[ ${x} == --no-merged ]]; then
      no_merged="--no-merged" # remotesは特別扱い

    elif [[ ${x} =~ -.* ]]; then
      # options
      options=("${options[*]}" "${x}")
    fi
  done

  # 引数がある場合は git branch を実行して終了
  [[ ${#options[*]} -gt 0 ]] && git branch "$@" && return

  local header
  header="${GRAY}*${NORMAL} KeyBindings                           ${GRAY}*${NORMAL} Change Options
| ${WHITE}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} ${YELLOW}${mode}${NORMAL} [branch]         | Ctrl+${WHITE}A${NORMAL} ❯ ${GREEN}fit${NORMAL} branch (all)
| Ctrl+${WHITE}N${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} branch -m                | Ctrl+${WHITE}G${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} branch merged
| Ctrl+${WHITE}D${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} branch -D (force)        | Ctrl+${WHITE}E${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} branch --no-merged
| Ctrl+${WHITE}L${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} log (multiselect)        | Ctrl+${WHITE}S${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} switch
                                        | Ctrl+${WHITE}R${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} merge
                                        | Ctrl+${WHITE}B${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}fit${NORMAL} rebase

"

  # コマンドを生成
  local git_branch fit_fzf
  git_branch="fit branch::branch-list ${merged} ${no_merged}"
  fit_fzf="fit::fzf \\
        --header \"$header\" \\
        --preview \"fit branch::preview {1}\" \\
        --bind \"ctrl-n:execute(fit branch::actions::call-git-branch-rename {1})+reload(eval $git_branch)\" \\
        --bind \"ctrl-d:execute(fit branch::actions::call-git-branch-delete {1})+reload(eval $git_branch)\" \\
        --bind \"ctrl-l:execute(fit log {1})\" \\
        --bind \"ctrl-a:abort+execute(fit branch)\" \\
        --bind \"ctrl-g:abort+execute(fit branch --merged)\" \\
        --bind \"ctrl-e:abort+execute(fit branch --no-merged)\" \\
        --bind \"ctrl-s:abort+execute(fit branch --switch)\" \\
        --bind \"ctrl-r:abort+execute(fit branch --merge)\" \\
        --bind \"ctrl-b:abort+execute(fit branch --rebase)\" \\
  "

  local branch
  branch=$(eval "${git_branch}" | eval "${fit_fzf}")

  if [[ $? == 0 ]]; then
    branch=$(echo "$branch" | awk '{ print $1 }')
    ! fit::utils::is-valid-branch "$branch" && echo "Please select branch name." && return

    if [[ $mode == "switch " ]]; then
      fit::branch::actions::call-git-switch "$branch"

    elif [[ $mode == "merge  " ]]; then
      fit::branch::actions::call-git-merge "$branch"

    elif [[ $mode == "rebase " ]]; then
      fit::branch::actions::call-git-rebase "$branch"

    else
      fit::branch::branch-list ${merged} ${no_merged}

    fi
  fi
}

fit::branch::branch-list() {
  local locals remotes
  locals=$(eval "fit git branch -vv $1 $2" | sed -e 's/\(^\* \|^  \)//g')
  remotes=$(eval "fit git branch -vv -r $1 $2" | sed -e 's/\(^\* \|^  \)//g')

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

  if ! fit::utils::is-valid-branch "$branch"; then
    # 不正なブランチ名の場合
    fit::utils::error-message "${RED}Please select branch name.${NORMAL}"
    return
  fi

  fit::utils::input-message new_branch "Please input new branch name."
  if ! git check-ref-format --branch "${new_branch}" >/dev/null 2>&1; then
    fit::utils::error-message "${RED}'${new_branch}' is not is not a valid branch name${NORMAL}"
    return
  fi

  if fit::utils::is-remote-branch "${branch}"; then
    # リモートはちょっと面倒
    local remote
    remote=$(git remote | head -1)
    local current_branch
    current_branch=$(git branch --show-current)

    local need_stash
    need_stash=$(git status --short)

    [[ -n $need_stash ]] && git stash               # スタッシュに隠す
    git switch -c "${new_branch}" -t "${branch}" && # 別名でチェックアウトする
      git push -u "${remote}" "${new_branch}" &&    # 別名でプッシュする
      git switch "${current_branch}"                # 元のブランチに帰ってくる
    [[ -n $need_stash ]] && git stash pop stash@{0} # 隠したスタッシュを戻して元通り

    # 元のリモートブランチは削除しますか？
    if ! fit::utils::confirm-message "${RED}Delete${NORMAL} old remote branch ${branch}?"; then
      return
    fi

    branch=$(echo "${branch}" | sed -e "s/^${remote}\///g")
    git push "${remote}" --delete "${branch}"

  else
    git branch -m "${branch}" "${new_branch}"
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
  if ! fit::utils::confirm-message "${RED}Delete${NORMAL} '${branch}' branch?"; then
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
