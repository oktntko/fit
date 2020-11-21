#!/usr/bin/env bash

fit::log() {
  local header
  header='🔹KeyBindings🔹
  ctrl + s   git add/restore       | 👆stage/👇unstage selected file.

  ctrl + u   git add -u, --update  | update index tracked files.
  ctrl + a   git add -A, --all     | update index all files.
  ctrl + p   git a/r -p, --patch   | stage by line not by file.

🔸Operation fzf🔸
  tab => toggle / alt + a => toggle-all

'

# TODO: 2つだけ選択して git diff 又は git difftool
# 流れ
# git fetch => git branch -r => git diff (分岐前) (最終コミット)
# fit branch => 詳細 => fit log => アクション => fit diff
# できそうなコマンド
# git diff [old commit] [new commit]
# git diff --name-only [old commit] [new commit]
# --- ファイル名の一覧
# git diff [old commit] [new commit] [ファイル名]
# --- ファイルの中の差分
# git show はその時点の差分又はファイルを表示するだけ
# git show HEAD:[ファイル名] でHEADのファイル名の中身を表示できる
# git diff HEAD^ HEAD と git show はファイルの差分としては同じ

  local reload
  reload="reload(fit log::list)"
  files=$(
    fit log::list |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --border=rounded \
        --no-mouse \
        --preview "fit log::list::extract {} | xargs fit log::preview" \
  )
}

fit::log::list() {
  git log --graph --oneline --decorate --color=always
}

fit::log::list::extract() {
  echo "$@" | grep -Eo '[a-f0-9]+' | head -1
}

fit::log::preview() {
  [[ -n $1 ]] && git show "$1" --decorate --color=always | eval "${FIT_PAGER_SHOW}"
}
