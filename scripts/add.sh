#!/usr/bin/env bash
forgit_diff_pager=${FORGIT_DIFF_PAGER:-$(git config pager.diff || echo "$forgit_pager")}

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && git status -su && return

  local files fzf_opts preview extract header git_add_p1 git_add_p
  # NOTE: paths listed by 'git status -su' mixed with quoted and unquoted style
  # remove indicators | remove original path for rename case | remove surrounding quotes
  extract="sed 's/^.*]  //' | sed 's/.* -> //' | sed -e 's/^\\\"//' -e 's/\\\"\$//'"

  preview="
        file=\$(echo {} | $extract)
        if (git status -s -- \$file | grep '^??') &>/dev/null; then  # diff with /dev/null for untracked files
            git diff --color=always --no-index -- /dev/null \$file | $forgit_diff_pager | sed '2 s/added:/untracked:/'
        else
            git diff --color=always -- \$file | $forgit_diff_pager
        fi
        "
  git_add_p1="
        file=\$(echo {} | $extract)
        git add -p \$file
  "
  git_add_p="
        file=\$(echo {} |$extract)
        less \$file
  "

  header='
  enter       ACCEPT.
  tab         Multi select.
  ctrl + p    patch

'
  fzf_opts="
      --ansi
      --header '$header'
      --layout=reverse
      --multi
      --cycle
      --bind=\"ctrl-p:execute($git_add_p)\"
"
  # ❯ git -c color.status=always -c status.relativePaths=true status -su
  # --------------------------------------------------------------------------------
  #  M fit
  #  M scripts/add.sh
  # ?? memo.txt
  # --------------------------------------------------------------------------------
  # ❯ sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1] \2/'
  # --------------------------------------------------------------------------------
  # [ M] fit
  # [ M] scripts/add.sh
  # [??] memo.txt
  # [\1] \2
  # -------------------------------------------------------------------------------
  files=$(git -c color.status=always -c status.relativePaths=true status -su |
    sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1]  \2/' |
    FZF_DEFAULT_OPTS="$fzf_opts" fzf --preview="$preview" |
    sh -c "$extract")
  # [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git add % && git status -su && return
}
