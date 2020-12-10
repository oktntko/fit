#!/usr/bin/env bash

# git push [--all | --mirror | --tags] [--follow-tags] [--atomic] [-n | --dry-run] [--receive-pack=<git-receive-pack>]
# 	   [--repo=<repository>] [-f | --force] [-d | --delete] [--prune] [-v | --verbose]
# 	   [-u | --set-upstream] [-o <string> | --push-option=<string>]
# 	   [--[no-]signed|--signed=(true|false|if-asked)]
# 	   [--force-with-lease[=<refname>[:<expect>]]]
# 	   [--no-verify] [<repository> [<refspec>…​]]

fit::push::fzf() {
  local remotes
  remotes=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

  # 確認しておきますか？
  if fit::utils::confirm-message "${YELLOW}need check diff ${remotes}..HEAD?${NORMAL}"; then
    fit::diff "${remotes}..HEAD"
    if ! fit::utils::confirm-message "${YELLOW}continue?"; then
      return
    fi
  fi

  git push
}
