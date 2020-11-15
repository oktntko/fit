#!/usr/bin/env bash

# OPTIONS
#        <pathspec>...
#            Files to add content from. Fileglobs (e.g.  *.c) can be given to add all matching files. Also a leading directory name (e.g.  dir to add
#            dir/file1 and dir/file2) can be given to update the index to match the current state of the directory as a whole (e.g. specifying dir will
#            record not just a file dir/file1 modified in the working tree, a file dir/file2 added to the working tree, but also a file dir/file3 removed
#            from the working tree). Note that older versions of Git used to ignore removed files; use --no-all option if you want to add modified or new
#            files but ignore removed ones.
#
#            For more details about the <pathspec> syntax, see the pathspec entry in gitglossary(7).
#
#        -n, --dry-run
#            Don’t actually add the file(s), just show if they exist and/or will be ignored.
#
#        -v, --verbose
#            Be verbose.
#
#        -f, --force
#            Allow adding otherwise ignored files.
#
#        -i, --interactive
#            Add modified contents in the working tree interactively to the index. Optional path arguments may be supplied to limit operation to a subset
#            of the working tree. See “Interactive mode” for details.
#
#        -p, --patch
#            Interactively choose hunks of patch between the index and the work tree and add them to the index. This gives the user a chance to review the
#            difference before adding modified contents to the index.
#
#            This effectively runs add --interactive, but bypasses the initial command menu and directly jumps to the patch subcommand. See “Interactive
#            mode” for details.
#
#        -e, --edit
#            Open the diff vs. the index in an editor and let the user edit it. After the editor was closed, adjust the hunk headers and apply the patch
#            to the index.
#
#            The intent of this option is to pick and choose lines of the patch to apply, or even to modify the contents of lines to be staged. This can
#            be quicker and more flexible than using the interactive hunk selector. However, it is easy to confuse oneself and create a patch that does
#            not apply to the index. See EDITING PATCHES below.
#
#        -u, --update
#            Update the index just where it already has an entry matching <pathspec>. This removes as well as modifies index entries to match the working
#            tree, but adds no new files.
#
#            If no <pathspec> is given when -u option is used, all tracked files in the entire working tree are updated (old versions of Git used to limit
#            the update to the current directory and its subdirectories).
#
#        -A, --all, --no-ignore-removal
#            Update the index not only where the working tree has a file matching <pathspec> but also where the index already has an entry. This adds,
#            modifies, and removes index entries to match the working tree.
#
#            If no <pathspec> is given when -A option is used, all files in the entire working tree are updated (old versions of Git used to limit the
#            update to the current directory and its subdirectories).
#
#        --no-all, --ignore-removal
#            Update the index by adding new files that are unknown to the index and files modified in the working tree, but ignore files that have been
#            removed from the working tree. This option is a no-op when no <pathspec> is used.
#
#            This option is primarily to help users who are used to older versions of Git, whose "git add <pathspec>..." was a synonym for "git add
#            --no-all <pathspec>...", i.e. ignored removed files.
#
#        -N, --intent-to-add
#            Record only the fact that the path will be added later. An entry for the path is placed in the index with no content. This is useful for,
#            among other things, showing the unstaged content of such files with git diff and committing them with git commit -a.
#
#        --refresh
#            Don’t add the file(s), but only refresh their stat() information in the index.
#
#        --ignore-errors
#            If some files could not be added because of errors indexing them, do not abort the operation, but continue adding the others. The command
#            shall still exit with non-zero status. The configuration variable add.ignoreErrors can be set to true to make this the default behaviour.
#
#        --ignore-missing
#            This option can only be used together with --dry-run. By using this option the user can check if any of the given files would be ignored, no
#            matter if they are already present in the work tree or not.
#
#        --no-warn-embedded-repo
#            By default, git add will warn when adding an embedded repository to the index without using git submodule add to create an entry in
#            .gitmodules. This option will suppress the warning (e.g., if you are manually performing operations on submodules).
#
#        --renormalize
#            Apply the "clean" process freshly to all tracked files to forcibly add them again to the index. This is useful after changing core.autocrlf
#            configuration or the text attribute in order to correct files added with wrong CRLF/LF line endings. This option implies -u.
#
#        --chmod=(+|-)x
#            Override the executable bit of the added files. The executable bit is only changed in the index, the files on disk are left unchanged.
#
#        --pathspec-from-file=<file>
#            Pathspec is passed in <file> instead of commandline args. If <file> is exactly - then standard input is used. Pathspec elements are separated
#            by LF or CR/LF. Pathspec elements can be quoted as explained for the configuration variable core.quotePath (see git-config(1)). See also
#            --pathspec-file-nul and global --literal-pathspecs.
#
#        --pathspec-file-nul
#            Only meaningful with --pathspec-from-file. Pathspec elements are separated with NUL character and all other characters are taken literally
#            (including newlines and quotes).
#
#        --
#            This option can be used to separate command-line options from the list of files, (useful when filenames might be mistaken for command-line
#            options).

#       •   M = modified
#       •   A = added
#       •   D = deleted
#       •   R = renamed
#       •   C = copied
#       •   U = updated but unmerged
#       •   ? = untracked

fit::add::preview() {
  local s file
  s=$1
  file=$2

  echo "$s" "$file"
  if [[ -f $file && $s != '??' ]]; then # ファイルで
    git diff HEAD -- "$file" | eval "${FIT_PAGER_DIFF}"
  elif [[ -f $file && $s == '??' ]]; then
    eval "${FIT_PREVIEW_FILE} $file"
  elif [[ -d $file ]]; then
    eval "${FIT_PREVIEW_DIRECTORY} $file"
  elif [[ ! -e $file ]]; then
    git diff HEAD -- "$file" | eval "${FIT_PAGER_DIFF}"
  fi
}

fit::add::status() {
  git -c color.ui=always -c status.relativePaths=true status -su
}
fit::add-u() {
  git add -u
}

fit::add-a() {
  git add -A
}

fit::add-p() {
  local s file
  s=$1
  file=$2

  # エディタを開く場合は </dev/tty >/dev/tty がないと
  # Input is not from a terminal
  # Output is not to a terminal
  # が出て動きが止まる
  git add -p "$file" </dev/tty >/dev/tty
}

fit::add() {
  # 引数がある場合は git add を実行して終了
  [[ $# -ne 0 ]] && git add "$@" && git status -su && return

  local header
  header='enter to ACCEPT. tab Multi select.

🔹KeyBindings🔹
  ctrl+u     ✔️ -u, --update    Update the index just where it already has an entry matching <pathspec>.
  ctrl+a     ✔️ -A, --all       Update the index not only where the working tree has a file matching <pathspec> but also where the index already has an entry.
  ctrl+p     💬 -p, --patch     Interactively choose hunks of patch between the index and the work tree and add them to the index.

'

  # --------------------------------------------------------------------------------
  #  M fit
  #  M scripts/add.sh
  # ?? memo.txt
  # --------------------------------------------------------------------------------

  # --preview や --execute で実行するコマンドはPATHが通っていないと実行できない
  # 例えば、nvm => NG だけど、nvm を使ってインストールした node => OK.
  local files reload
  reload="reload(fit add::status)"
  files=$(
    fit add::status |
      fzf \
        --ansi \
        --header "$header" \
        --layout=reverse \
        --multi \
        --cycle \
        --border=rounded \
        --preview "fit add::preview {1} {2..}" \
        --bind "ctrl-u:execute(fit add-u)+$reload" \
        --bind "ctrl-a:execute(fit add-a)+$reload" \
        --bind "ctrl-p:execute(fit add-p {1} {2..})+$reload"
  )
  echo $files
  # [[ -n "$files" ]] && echo "$files" | tr '\n' '\0' | xargs -0 -I% git add % && git status -su && return
}
