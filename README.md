# fit

`fit` は `git` をラップして目に優しくしたもの。

## Description

**_DEMO:_**

![Demo](https://image-url.gif)

## 📝 Usage

### commit group
  - `fit commit` -> Enter to commit.
  - `fit status` -> show preview.
  - `fit stage/add` -> Enter to add.
  - `fit unstage/restore` -> Enter to restore --staged.

#### window
  一覧は`git status(ファイル名)` 
  プレビューは`git diff`
  詳細表示は`git show`
  
#### action
  `git stage/add` ✅multi select.
  `git unstage/restore --staged` ✅multi select.
  `git add --patch`
  `git restore --staged --patch`
  `git restore --worktree `

  `edit file`

### branch group
  - `fit switch` -> Enter to switch.
  - `fit branch` -> show preview.
  - `fit merge` -> Enter to merge.
  - `fit rebase` -> Enter to rebase.

#### window
   -> switch するコミットを選択できる
   -> KeyBind で ローカルブランチ/リモートブランチ/refs/log から選択できる
   => Enter で選択したコミットが補完
   ローカルなら何もなし
   リモートなら -t
   refs/log なら -b

### log group
  - `fit log` -> TBD.
  - `fit reflog` -> TBD.

### stash group
  - `fit stash` -> TBD.

### TBD
3. `fit diff`
4. `fit grep`

## Requirement

- [`fzf`](https://github.com/junegunn/fzf)
- [`git`](https://git-scm.com/)

## 📥 Installation

```zsh
# for zplug
zplug 'oktntko/fit'
```

## Anything Else

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
