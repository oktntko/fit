#!/usr/bin/env bash

# git pull [<options>] [<repository> [<refspec>…​]]

fit::pull::fzf() {
  local remotes before_head
  before_head=$(git rev-parse HEAD)
  remotes=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

  git pull

  # 確認しておきますか？
  if ! git diff "${before_head}" "${remotes}" --exit-code --quiet; then
    # git diff --exit-code / true: 差分がない / false: 差分がある
    # の否定系で差分がある時だけ確認メッセージを表示する
    if fit::utils::confirm-message "${YELLOW}Check pulled diff ?"; then
      fit::diff "${before_head}" "${remotes}"
    fi
  fi
}
