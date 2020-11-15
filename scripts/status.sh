#!/usr/bin/env bash

fit::status() {
  local header
  header='🔹KeyBindings🔹
  ctrl + s   git add/reset   👆stage/👇unstage selected file.
  ctrl + u   git add -u       Update the index just where it already has an entry matching <pathspec>.
  ctrl + a   git add -A       Update the index not only where the working tree has a file matching <pathspec> but also where the index already has an entry.
  ctrl + p   git add -p       Interactively choose hunks of patch between the index and the work tree and add them to the index.

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
        --bind "ctrl-p:execute(fit add-p {1} {2..})+$reload"
  )
  fit status::list
}

fit::status::list() {
  git -c color.ui=always -c status.relativePaths=true status -su
  # ex)
  # --------------------------------------------------------------------------------
  #  M fit
  #  M scripts/add.sh
  # ?? memo.txt
  # --------------------------------------------------------------------------------
}

# M = modified
# A = added
# D = deleted
# R = renamed
# C = copied
# U = updated but unmerged
# ? = untracked

fit::status::is-staged() {
  git diff --name-only --cached | grep -qE ^"$1"$
}

fit::status::change() {
  local file
  file=$1

  if fit::status::is-staged "$file"; then
    git reset -- "$file"
  else
    git add -- "$file"
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
