#!/usr/bin/env bash

# ファイル操作系
# status
# add/stage
# restore/unstage
# commit
fit::status() {
  local mode
  mode="status"
  [[ $1 == "--add" || $1 == "-a" ]] && mode="add" && shift
  [[ $1 == "--restore" || $1 == "-r" ]] && mode="restore" && shift
  [[ $1 == "--commit" || $1 == "-c" ]] && mode="commit" && shift

  # header のだし分け
  local header
  header="🔹KeyBindings🔹"
  if [[ $mode == "add" ]]; then
    header="${header}
  ${YELLOW}${BOLD}ctrl + s${NORMAL}   git add                       | 👆stage selected file."

  elif [[ $mode == "restore" ]]; then
    header="${header}
  ${YELLOW}${BOLD}ctrl + s${NORMAL}   git restore                   | 👇unstage selected file."

  else
    header="${header}
  ${YELLOW}${BOLD}ctrl + s${NORMAL}   git add/restore               | 👆stage/👇unstage selected file."

  fi

  header="${header}

  ctrl + u  : update index tracked files.  | ctrl + r  : restore file change
  ctrl + a  : update index all files.      |
  ctrl + p  : select update index by line. |

🔸Operation fzf🔸
  tab => toggle / alt + a => toggle-all

"

  # add の場合 unstaging なファイルのみ/restore の場合 staging なファイルのみ表示
  local s filter
  if [[ $mode == "add" ]]; then
    filter="--unstaging-only"

  elif [[ $mode == "restore" ]]; then
    filter="--staging-only"

  fi

  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  s="fit core::status ${filter}"
  reload="reload(eval $s)"
  files=$(
    eval "$s" |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --multi \
        --cycle \
        --border=rounded \
        --preview "fit status::preview {1} {2}" \
        --bind "ctrl-s:execute-silent(fit status::change {2})+down+$reload" \
        --bind "ctrl-u:execute-silent(fit add-u)+$reload" \
        --bind "ctrl-a:execute-silent(fit add-a)+$reload" \
        --bind "ctrl-p:execute(fit status::patch {2})+$reload" \
        --bind "ctrl-r:execute-silent(fit restore::worktree {2})+$reload" \
        --bind "alt-a:toggle-all"
  )
  if [[ $? == 0 ]]; then
    if [[ $mode == "add" ]]; then
      [[ -n "$files" ]] && echo "$files" | awk -v 'ORS= ' '{ print $2 }' | xargs git add

    elif [[ $mode == "restore" ]]; then
      [[ -n "$files" ]] && echo "$files" | awk -v 'ORS= ' '{ print $2 }' | xargs git restore --staged

    elif [[ $mode == "commit" ]]; then
      git commit "$@" && return
    fi
  fi

  git status && return
}

# /*
# 引数のファイルの stage/unstage を切り替える
# @param string[] files.
# */
fit::status::change() {
  for file in "$@"; do
    if fit::core::status::is-staging "$file"; then
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
fit::status::patch() {
  local file
  file=$1

  # エディタを開く場合は </dev/tty >/dev/tty がないと
  # Input is not from a terminal
  # Output is not to a terminal
  # が出て動きが止まる
  if fit::core::status::is-staging "$file"; then
    git restore -S -p "$file" </dev/tty >/dev/tty
  else
    git add -p "$file" </dev/tty >/dev/tty
  fi
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
  # TODO: [R]renameに対応できていないと思われる
}
