背景

WSL2に移行したこと。
元々tortoise git(+winmerge)とgit コマンドラインを使っていた。
tortoise gitが使えなくなったわけじゃないけど。
tigはちょっとしか使ってない。

目的
tortoiseGitの操作感のtuiがほしい。
tui色々あるけど、gitのコマンド叩くのと変わらない操作感で使いたい。
キーバインドを覚えてれない。
gitコマンドの延長くらいで新しいものはない。

初心者向けに、gitコマンドを覚えてほしい。　

インスパイア
forgit
fuzzy git
やろうと思ったきっかけ。ソースもこの2つからとってきてる。
tortoiseGit
やりたいのは大体これ。でももう少しコマンドライン寄りにしたい。
lazy git
gitui
すげぇ！くらい。でもやりすぎ感。

よく使うコマンド
git commit -m "こめんと"
git add .
git push
git checkout -b brachname origin/branchname
git branch -u
git push -u origin branchname
git merge --no-ff --log branchname
git pull --rebase
git fetch -p
git branch -D branchname
git push origin --delete branchname
git checkout .
git rebase branchname
git checkout branchname
git commit --amend --no-edit

背伸びせずに書くとこんな感じか。
他は使わないわけではないけど頻度は低い。
