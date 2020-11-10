#!/usr/bin/env bash
forgit_diff_pager=${FORGIT_DIFF_PAGER:-$(git config pager.diff || echo "$forgit_pager")}
fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && git status -su && return

  local files opts preview extract
  # NOTE: paths listed by 'git status -su' mixed with quoted and unquoted style
  # remove indicators | remove original path for rename case | remove surrounding quotes
  extract="
        sed 's/^.*]  //' |
        sed 's/.* -> //' |
        sed -e 's/^\\\"//' -e 's/\\\"\$//'
        "
  preview="
        file=\$(echo {} | $extract)
        if (git status -s -- \$file | grep '^??') &>/dev/null; then  # diff with /dev/null for untracked files
            git diff --color=always --no-index -- /dev/null \$file | $forgit_diff_pager | sed '2 s/added:/untracked:/'
        else
            git diff --color=always -- \$file | $forgit_diff_pager
        fi
        "
  opts="
        $FORGIT_FZF_DEFAULT_OPTS
        -0 -m --nth 2..,..
        $FORGIT_ADD_FZF_OPTS
        "
  files=$(
    git -c color.status=always -c status.relativePaths=true status -su |
    # --------------------------------------------------------------------------------
    #  M fit
    #  M scripts/add.sh
    # ?? memo.txt
    # --------------------------------------------------------------------------------
      sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1]  \2/' |
    # --------------------------------------------------------------------------------
    # [ M]  fit
    # [ M]  scripts/add.sh
    # [??]  memo.txt
    # [\1]  \2
    # --------------------------------------------------------------------------------
      FZF_DEFAULT_OPTS="$opts" fzf --preview="$preview" |
      sh -c "$extract"
  )
  [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git add % && git status -su && return
  echo 'Nothing to add.'
}
