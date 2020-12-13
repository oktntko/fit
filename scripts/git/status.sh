#!/usr/bin/env bash

# M = modified
# A = added
# D = deleted
# R = renamed
# C = copied
# U = updated but unmerged
# ? = untracked

# ファイル操作系
# status
# add/stage
# restore/unstage
# commit

# git status [<options>…​] [--] [<pathspec>…​]

fit::status::fzf() {
  local mode
  mode="status "
  [[ $1 == "--add" || $1 == "-a" ]] && mode="add    " && shift
  [[ $1 == "--restore" || $1 == "-r" ]] && mode="restore" && shift
  [[ $1 == "--commit" || $1 == "-c" ]] && mode="commit " && shift

  # header のだし分け
  local header
  header="${GRAY}*${NORMAL} KeyBindings                           ${GRAY}*${NORMAL} Change Options
| ${WHITE}${S_UNDERLINE}ENTER${NORMAL}  ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} ${YELLOW}${mode}${NORMAL}
| Ctrl+${WHITE}S${NORMAL} ${WHITE}❯${NORMAL} stage/unstage (multiselect)  | Ctrl+${WHITE}E${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}EDIT${NORMAL} [file]
| Ctrl+${WHITE}A${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} add -A                   | Ctrl+${WHITE}D${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}rm${NORMAL} [file]
| Ctrl+${WHITE}R${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} restore (multiselect)
| Ctrl+${WHITE}P${NORMAL} ${WHITE}❯${NORMAL} ${GREEN}git${NORMAL} stage/unstage --patch

"

  # TODO: add の場合 unstaging なファイルのみ/restore の場合 staging なファイルのみ表示
  local statuses

  # TODO: [R]renameに対応できていないと思われる
  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  statuses="fit status-all"
  reload="reload(eval $statuses)"
  files=$(
    eval "$statuses" |
      fit::fzf \
        --header "$header" \
        --multi \
        --preview "fit status::preview {1} {2}" \
        --bind "ctrl-s:execute-silent(fit status::actions::change-status {+2})+$reload" \
        --bind "ctrl-a:execute-silent(fit status::actions::call-git-add-all)+$reload" \
        --bind "ctrl-r:execute-silent(fit status::actions::call-git-restore-worktree {+2})+$reload" \
        --bind "ctrl-p:execute(fit status::actions::patch-status {2})+$reload" \
        --bind "ctrl-d:execute-silent(fit utils::remove-file {2})+$reload" \
        --bind "ctrl-e:execute(fit utils::edit-file {2})+$reload" \
  )
  if [[ $? == 0 ]]; then
    if [[ $mode == "add    " ]]; then
      [[ -n "$files" ]] && echo "$files" | awk '{ print $2 }' | fit::utils::valid-files | xargs git add

    elif [[ $mode == "restore" ]]; then
      [[ -n "$files" ]] && echo "$files" | awk '{ print $2 }' | fit::utils::valid-files | xargs git restore --staged

    elif [[ $mode == "commit " ]]; then
      git commit "$@" && return

    else
      git status && return

    fi
  fi
}

# /*
# 引数のファイルのindexの状態を判定する
# @option --staging-only
# @option --unstaging-only
# @return boolean true: is staging/ false: not staging.
# */
fit::status-all() {
  local statuses
  statuses=$(fit git status -su)

  local stating unstaging untracked
  stating=$(echo "${statuses}" | fit status::list-files --staging-only)
  unstaging=$(echo "${statuses}" | fit status::list-files --unstaging-only)
  untracked=$(echo "${statuses}" | fit status::list-files --untracked-only)

  if [[ -n $stating ]]; then
    echo "${GREEN}Changes to be committed:${NORMAL}"
    echo "${stating}"
    [[ -n $unstaging ]] || [[ -n $untracked ]] && echo
  fi

  if [[ -n $unstaging ]]; then
    echo "${RED}Changes not staged for commit:${NORMAL}"
    echo "${unstaging}"
    [[ -n $untracked ]] && echo
  fi

  if [[ -n $untracked ]]; then
    echo "${YELLOW}Untracked files:${NORMAL}"
    echo "${untracked}"
  fi
}

fit::status::list-files() {
  local filter
  if [[ $1 == --staging-only ]]; then
    # git diff --name-only --staged => staged な変更を表示する
    filter=$(git diff --name-only --staged)
  elif [[ $1 == --unstaging-only ]]; then
    # git diff --name-only          => unstaged な変更を表示する
    filter=$(git diff --name-only)
  elif [[ $1 == --untracked-only ]]; then
    # git ls-files --others --exclude-standard =>
    #    others           : 管理対象外のファイル
    #    exclude-standard : .gitignoreで無視されているファイルを除く
    filter=$(git ls-files --others --exclude-standard)
  fi

  [[ -z $filter ]] && return

  local grfile
  grfile="grep --color=never "
  while IFS= read -r line; do
    grfile="${grfile} -e ${line}"
  done < <(echo "$filter")

  eval "${grfile}"
}

fit::status::preview() {
  local s file
  s=$1
  file=$2

  echo "$s" "$file" # TODO: 色付け

  if [[ -f $file && $s != '??' ]]; then # tracked file => git diff.
    git diff HEAD -- "$file" | eval "${FIT_PAGER_DIFF}"
  elif [[ -f $file && $s == '??' ]]; then # untracked file => show preview.
    eval "${FIT_PREVIEW_FILE} $file"
  elif [[ -d $file ]]; then # directory => show tree.
    eval "${FIT_PREVIEW_DIRECTORY} $file"
  elif [[ ! -e $file ]]; then # deleted file => git diff.
    git diff HEAD -- "$file" | eval "${FIT_PAGER_DIFF}"
  fi
}

# /*
# 引数のファイルの stage/unstage を切り替える
# @param string[] files.
# */
fit::status::actions::change-status() {
  for file in "$@"; do
    if fit::utils::status-is-staging "$file"; then
      git restore --staged "$file"
    else
      git add -- "$file"
    fi
  done
}

# /*
# git add/restore --patchの実行
# @param string file.
# */
fit::status::actions::patch-status() {
  local file
  file=$1

  ! fit::utils::is-valid-file "$1" && return

  # エディタを開く場合は </dev/tty >/dev/tty がないと
  # Input is not from a terminal
  # Output is not to a terminal
  # が出て動きが止まる
  if ! fit::utils::status-is-staging "$file"; then
    git add -p "$file" </dev/tty >/dev/tty
  else
    git restore -S -p "$file" </dev/tty >/dev/tty
  fi
}

fit::status::actions::call-git-add-all() {
  git add -A
}

# /*
# 引数のファイルの変更を取り消す
# @param string[] files.
# */
fit::status::actions::call-git-restore-worktree() {
  # TODO: ファイルがstaging 状態だと利かない
  for file in "$@"; do
    # git restore --worktree -> worktree をrestoreする(HEADに合わせる)
    # git restore --staged   -> staging  をrestoreする(HEADに合わせる)
    git restore --source=HEAD --staged --worktree "$file"
  done
}
