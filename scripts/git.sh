#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# diff group
# --------------------------------------------------------------------------------
fit::diff() {
  fit::core::diff "$@"
}

# --------------------------------------------------------------------------------
# status group
# --------------------------------------------------------------------------------
fit::commit() {
  fit::status --commit "$@"
}

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && return

  fit::status --add
}

fit::stage() {
  fit::add "$@"
}

fit::restore() {
  # restore --staged             => stage状態を取り消す. stage/unstage
  # restore --worktree(default)  => 変更を取り消す. checkout/reset --hard
  # 引数がある場合は git restore を実行して終了
  [[ $# -ne 0 ]] && git restore "$@" && return

  fit::status --restore
}

fit::unstage() {
  fit::restore "$@"
}

# --------------------------------------------------------------------------------
# branch group
# --------------------------------------------------------------------------------
fit::branch() {
  fit::branch::fzf "$@"
}

fit::switch() {
  # 引数がある場合は git switch を実行して終了
  [[ $# -ne 0 ]] && git switch "$@" && return

  fit::branch::fzf --switch "$@"
}

fit::rebase() {
  # 引数がある場合は git rebase を実行して終了
  [[ $# -ne 0 ]] && git rebase "$@" && return

  fit::branch::fzf --rebase "$@"
}

fit::merge() {
  # 引数がある場合は git merge を実行して終了
  [[ $# -ne 0 ]] && git merge "$@" && return

  fit::branch::fzf --merge "$@"
}

# --------------------------------------------------------------------------------
# log group
# --------------------------------------------------------------------------------
fit::log() {
  fit::log::fzf "$@"
}
# --------------------------------------------------------------------------------
# stash group
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# reflog group
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# push group
# --------------------------------------------------------------------------------
fit::push() {
  # 引数がある場合は git rebase を実行して終了
  [[ $# -ne 0 ]] && git push "$@" && return

  if ! git push --dry-run >/dev/null 2>&1; then
    git push --dry-run
    return
  fi

  local remotes
  remotes=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

  # 確認しておきますか？
  if fit::utils::confirm-message "${YELLOW}need check diff HEAD..${remotes}${NORMAL}?"; then
    fit::diff "HEAD..${remotes}"
    [[ $? == 0 ]] && return
  fi

  git push
}
