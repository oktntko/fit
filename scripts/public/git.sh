#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# diff group
# --------------------------------------------------------------------------------
fit::diff() {
  fit::core::diff "$@"
}

# --------------------------------------------------------------------------------
# commit group
# --------------------------------------------------------------------------------
fit::commit() {
  fit status --commit "$@"
}

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && return

  fit status --add
}

fit::stage() {
  fit add "$@"
}

# restore --staged             => stage状態を取り消す. stage/unstage
# restore --worktree(default)  => 変更を取り消す. checkout/reset --hard
fit::restore() {
  # 引数がある場合は git restore を実行して終了
  [[ $# -ne 0 ]] && git restore "$@" && return

  fit status --restore
}

fit::unstage() {
  fit restore "$@"
}

# --------------------------------------------------------------------------------
# branch group
# --------------------------------------------------------------------------------

fit::switch() {
  # 引数がある場合は git switch を実行して終了
  [[ $# -ne 0 ]] && git switch "$@" && return

  fit branch --switch "$@"
}

fit::rebase() {
  # 引数がある場合は git rebase を実行して終了
  [[ $# -ne 0 ]] && git rebase "$@" && return

  fit branch --rebase "$@"
}

fit::merge() {
  # 引数がある場合は git merge を実行して終了
  [[ $# -ne 0 ]] && git merge "$@" && return

  fit branch --merge "$@"
}

# --------------------------------------------------------------------------------
# log group
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# stash group
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# reflog group
# --------------------------------------------------------------------------------
