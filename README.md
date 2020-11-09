# fit

`fit` は `git` をラップして目に優しくしたもの。

## Description

**_DEMO:_**

![Demo](https://image-url.gif)

## 📝 Usage

### action

1. `fit commit`
   -> staging と unstaging を選択できる
   -> Enter でコミット
2. `fit add/restore`
   -> add/restore するファイルを選択できる
   -> Enter で選択したファイルが並ぶ
3. `fit switch`
   -> switch するコミットを選択できる
   -> KeyBind で ローカルブランチ/リモートブランチ/refs/log から選択できる
   => Enter で選択したコミットが補完
   ローカルなら何もなし
   リモートなら -t
   refs/log なら -b
4. `fit stash`
   -> `stash` コマンドが選べる
   `fit stash list` `fit stash pop` `fit stash clean` ...

### preview

1. `fit status`
2. `fit log/reflog`
   -> 左側に log 右側にプレビュー
   -> プレビューは選べたら KeyBind で選ぶ
3. `fit diff`
4. `fit grep`
5. `fit branch`

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
