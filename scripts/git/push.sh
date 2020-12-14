#!/usr/bin/env bash

# git push [--all | --mirror | --tags] [--follow-tags] [--atomic] [-n | --dry-run] [--receive-pack=<git-receive-pack>]
# 	   [--repo=<repository>] [-f | --force] [-d | --delete] [--prune] [-v | --verbose]
# 	   [-u | --set-upstream] [-o <string> | --push-option=<string>]
# 	   [--[no-]signed|--signed=(true|false|if-asked)]
# 	   [--force-with-lease[=<refname>[:<expect>]]]
# 	   [--no-verify] [<repository> [<refspec>…​]]

fit::push::fzf() {
  local remotes head
  head=$(git rev-parse HEAD)
  remotes=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

  # 確認しておきますか？
  if fit::utils::confirm-message "${YELLOW}Check push diff?${NORMAL}"; then
    fit::diff "${remotes}" "${head}"
    if ! fit::utils::confirm-message "${YELLOW}Continue?${NORMAL}"; then
      return
    fi
  fi

  git push
}
