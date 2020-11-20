#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# preview
# --------------------------------------------------------------------------------
# pager
export FIT_PAGER="${FIT_PAGER:-$(git config core.pager || echo 'cat')}"
export FIT_PAGER_SHOW="${FIT_PAGER_SHOW:-$(git config pager.show || echo "$FIT_PAGER")}"
export FIT_PAGER_DIFF="${FIT_PAGER_DIFF:-$(git config pager.diff || echo "$FIT_PAGER")}"

# show file
export FIT_PREVIEW_FILE="bat --color=always"

# show directory
export FIT_PREVIEW_DIRECTORY="exa -l --color=always"

export FIT_CORE_BRANCH_MODE="" # local(default) | remotes | all

export FIT_EDITOR="${FIT_EDITOR:-$(git config --get core.editor || echo "$EDITOR" || echo 'vi')}"

export FIT_MERGE_OPTION="${FIT_MERGE_OPTION:-""}"
export FIT_REBASE_OPTION="${FIT_REBASE_OPTION:-""}"
