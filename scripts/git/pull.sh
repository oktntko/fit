#!/usr/bin/env bash

# git pull [<options>] [<repository> [<refspec>…​]]

fit::pull::fzf() {
  local remotes before_head
  before_head=$(git rev-parse HEAD)
  remotes=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

  git pull

  # 確認しておきますか？
  if fit::utils::confirm-message "${YELLOW}Check pulled diff?"; then
    fit::diff "${before_head}..${remotes}"
  fi
}
