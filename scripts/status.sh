#!/usr/bin/env bash

# ファイル操作系
# status
# add/stage
# restore/unstage
# commit
fit::status() {
  local header
  header='🔹KeyBindings🔹
  ctrl + s   git add/restore       | 👆stage/👇unstage selected file.

  ctrl + u   git add -u, --update  | update index tracked files.
  ctrl + a   git add -A, --all     | update index all files.
  ctrl + p   git a/r -p, --patch   | stage by line not by file.

🔸Operation fzf🔸
  tab => toggle / alt + a => toggle-all

'

  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  local reload
  reload="reload(fit status::list)"
  files=$(
    fit status::list |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --multi \
        --cycle \
        --border=rounded \
        --preview "fit status::preview {1} {2..}" \
        --bind "ctrl-s:execute-silent(fit status::change {2..})+$reload" \
        --bind "ctrl-u:execute-silent(fit add-u)+$reload" \
        --bind "ctrl-a:execute-silent(fit add-a)+$reload" \
        --bind "ctrl-p:execute(fit status::patch {2..})+$reload" \
        --bind "alt-a:toggle-all"
  )
  # status では何もしない
  # [[ -n "$files" ]] && echo "$files" | fit status::list::extract | xargs fit status::change && git status && return
  git status && return
}

# /*
#
# @return
# --------------------------------------------------------------------------------
#  M fit
#  M scripts/add.sh
# ?? memo.txt
# --------------------------------------------------------------------------------
# */
fit::status::list() {
  git -c color.ui=always -c status.relativePaths=true status -su
}

# /*
# @return
# --------------------------------------------------------------------------------
# fit scripts/add.sh memo.txt
# --------------------------------------------------------------------------------
# */
fit::status::list::extract() {
  awk -v 'ORS= ' '{ print $2 }'
}
# M = modified
# A = added
# D = deleted
# R = renamed
# C = copied
# U = updated but unmerged
# ? = untracked

# /*
# 引数のファイルのindexの状態を判定する
# @param string file.
# @return boolean true: is staging/ false: not staging.
# */
fit::status::is-staging() {
  git diff --name-only --staged | grep -qE ^"$1"$
}

# /*
# 引数のファイルの stage/unstage を切り替える
# @param string[] files.
# */
fit::status::change() {
  for file in "$@"; do
    if fit::status::is-staging "$file"; then
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

  if fit::status::is-staging "$file"; then
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
