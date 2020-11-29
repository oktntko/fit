# fit

`fit` は `git` をラップして目に優しくしたもの。

# Description

**_DEMO:_**

![Demo](https://image-url.gif)

# 📝 Usage

## status group
  - `fit commit` -> Enter to commit.
  - `fit status` -> show preview.
  - `fit stage/add` -> Enter to add.
  - `fit unstage/restore` -> Enter to restore --staged.

### window
  一覧は`git status(ファイル名)` 
  プレビューは`git diff`
  詳細表示は`git show`
  
### keybindings action
  - `git stage/add` ✅multi select.
  - `git unstage/restore --staged` ✅multi select.
  - `git add --patch`
  - `git restore --staged --patch`
  - `git restore --worktree `

  - `edit file`

### accept action
  - `git commit`
  - `git stage/add`
  - `git unstage/restore`

## branch group
  - `fit switch` -> Enter to switch.
  - `fit branch` -> show preview.
  - `fit merge` -> Enter to merge.
  - `fit rebase` -> Enter to rebase.

### window
  一覧は`git branch(ブランチ名)` 
  プレビューは`git log`
  詳細表示は`git ?`

### keybindings action
  - `git branch --delete`
  - 

### accept action
  - `git switch`
  - `git merge`
  - `git rebase`

## log group
  - `fit log` -> TBD.

### window
  一覧は`git log(コミット名)` 
  プレビューは`git show`
  詳細表示は`git ?`

### keybindings action
  - `git switch` -> ブランチを作成
  - `git revert` -> revert

### accept action

## reflog group
  - `fit reflog` -> TBD.

### window
  一覧は`git reflog(コミット名)` 
  プレビューは`git show`
  詳細表示は`git ?`

### keybindings action
  - `git switch` -> ブランチを作成
  - `git revert` -> revert

### accept action

## stash group
  - `fit stash` -> TBD.

## TBD
3. `fit diff`
4. `fit grep`

# Requirement

- [`fzf`](https://github.com/junegunn/fzf)
- [`git`](https://git-scm.com/)

# 📥 Installation

```zsh
# for zplug
zplug "oktntko/fit", as:command, use:fit
```

# Anything Else

AnythingAnythingAnything
AnythingAnythingAnything
AnythingAnythingAnything

## 📦 Optional dependencies

- [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) or [`delta`](https://github.com/dandavison/delta)

- [`bat`](https://github.com/sharkdp/bat.git)

- [`tree`](https://github.com/nodakai/tree-command)

## 💡 Tips

## Author

@oktntko

## 📃 License

MIT
