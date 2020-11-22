#!/usr/bin/env bash

fit::log() {
  # 引数がある場合は git log を実行して終了
  [[ $# -ne 0 ]] && git log "$@" && return

  local header
  header="🔹KeyBindings🔹
  Ctrl+D select two commit and Ctrl+D then git diff.

"

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

  fit core::log |
    fzf \
      --ansi \
      --header "$header" \
      --layout=reverse \
      --border=rounded \
      --no-mouse \
      --multi \
      --preview "fit core::log::extract {} {+}" \
      --bind "ctrl-d:execute(fit log::diff --current-line {} --multi-select-line {+})"

  fit core::log -10 && return
}

fit::log::preview() {
  [[ -n $1 ]] && git show "$1" --decorate --color=always | eval "${FIT_PAGER_SHOW}"
}

fit::log::diff() {
  declare -a current_line=
  declare -a multi_select_lines=()

  while (($# > 0)); do
    case $1 in
    --*)
      if [[ $1 == --current-line ]]; then
        nflag='-n'
      fi
      if [[ $1 == --multi-select-lines ]]; then
        lflag='-l'
      fi
      shift
      ;;
    *)
      multi_select_lines=("${multi_select_lines[@]}" "$1")
      shift
      ;;
    esac
  done

  fit::diff "n[${n}]" "line[${line}]" "commits[${commits}]"
}
