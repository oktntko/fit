#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# preview
# --------------------------------------------------------------------------------
# pager
export FIT_PAGER="${FIT_PAGER:-$(git config core.pager || echo 'cat')}"
export FIT_PAGER_SHOW="${FIT_PAGER_SHOW:-$(git config pager.show || echo "$FIT_PAGER")}"
export FIT_PAGER_DIFF="${FIT_PAGER_DIFF:-$(git config pager.diff || echo "$FIT_PAGER")}"

# fzf
export FIT_PREVIEW_POSITION="${FIT_PREVIEW_POSITION:-right}"
export FIT_PREVIEW_SIZE="${FIT_PREVIEW_SIZE:-50%}"
export FIT_PREVIEW_BORDER_SHAPE="${FIT_PREVIEW_BORDER_SHAPE:-rounded}"
export FIT_PREVIEW_WRAP="${FIT_PREVIEW_WRAP:-nowrap}"
export FIT_PREVIEW_CYCLE="${FIT_PREVIEW_CYCLE:-nocycle}"
export FIT_PREVIEW_HIDDEN="${FIT_PREVIEW_HIDDEN:-nohidden}"


# show file
export FIT_PREVIEW_FILE="bat --color=always"

# show directory
export FIT_PREVIEW_DIRECTORY="exa -l --color=always"

export FIT_CORE_BRANCH_MODE="" # local(default) | remotes | all

export FIT_EDITOR="${FIT_EDITOR:-$(git config --get core.editor || echo "$EDITOR" || echo 'vi')}"

export FIT_MERGE_OPTION="${FIT_MERGE_OPTION:-"--no-ff --log"}"
export FIT_REBASE_OPTION="${FIT_REBASE_OPTION:-""}"