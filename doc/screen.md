# 画面設計

## 基本の画面構成

```
+----------------------------------------------------------------------+
| +------------------------------+ +---------------------------------+ |
| | メッセージ                   | |   プレビュー                    | |
| |                              | |                                 | |
| |                              | |                                 | |
| +------------------------------+ |                                 | |
| +------------------------------+ |                                 | |
| | メインビュー                 | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| |                              | |                                 | |
| +------------------------------+ +---------------------------------+ |
+----------------------------------------------------------------------+
```

## 画面の要素
1. メインビューに何を表示するか？
  - git log 
  - git status
  - git diff --name-only
  - git branch

2. プレビューに何を表示するか？
  - `git log              => git show`
  - `git status           => git diff`
  - `git diff --name-only => git diff`
  - `git branch           => git log`

3. 何ができるか？
  - メインアクション(Enter) => `git add` で表示したウィンドウなら `git add`する
  - 詳細表示アクション(Alt+D) => プレビューをメインビューへ
  - サブアクション(Ctrl+?) => 各種サブアクション
  - 予約済みのアクション
    - プレビューのオン/オフ(Alt+R)
    - プレビューの操作(Alt+↑↓←→)
    - 全選択/選択切り替え/全非選択(Alt+A/Alt+S/AltD)

## 操作シナリオ
1. 作業ブランチのコミット＆プッシュ
- `git switch main`
- `git pull`
- `git switch -c hoge`
- ファイル操作
- `git add .`
- `git commit -m "comment"`
- `git push -u origin hoge`

2. マージコミット
- `git fetch`
- `git branch -r`
- `git log --oneline -10 target_branch`
- `git diff [マージするブランチの枝分かれ元] [マージするブランチの枝分かれ最後]`
- `git switch -t target_branch`
- `git switch main`
- `git pull`
- `git merge --no-ff --log target_branch`
- `git push`

## 参考
### fuzzy git
- `status`
- `branch`
- `log`
- `reflog`
- `stash`
- `diff`

### tig
- `m view-main           Show main view`
- `d view-diff           Show diff view`
- `l view-log            Show log view`
- `t view-tree           Show tree view`
- `f view-blob           Show blob view`
- `b view-blame          Show blame view`
- `r view-refs           Show refs view`
- `s view-status         Show status view`
- `c view-stage          Show stage view`
- `y view-stash          Show stash view`
- `g view-grep           Show grep view`
- `p view-pager          Show pager view`
- `h view-help           Show help view`

### forgit
- `git add(ga)`
- `git log(glo)`
- `gitignore(gi)`
- `git diff(gd)`
- `git reset HEAD <file>(grh)`
- `git checkout <file>(gcf)`
- `git stash(gss)`
- `git clean(gclean)`
- `git cherry-pick(gcp)`
- `git rebase -i(grb)`

## 画面一覧
- commit
- branch
- log
- diff
- reflog
- stash

```
branch                                           log                                           diff

 +---------------------------------------+        +---------------------------------------+     +---------------------------------------+
 | +-----------------+ +---------------+ |        | +-----------------+ +---------------+ |     | +-----------------+ +---------------+ |
 | |comment          | |git log        | |        | |comment          | |git diff Xv X  | |     | |comment          | |git diff       | |
 | +-----------------+ |               | |        | +-----------------+ |(Summary)      | |     | +-----------------+ |               | |
 | +-----------------+ |               | |        | +-----------------+ +---------------+ |     | +-----------------+ |               | |
 | |git branch       | |               | +--------> |git log          | |git show       | +-----> |git diff --name- | |               | |
 | |                 | |               | |        | |                 | |               | |     | | only            | |               | |
 | |                 | |               | |        | |                 | |               | |     | |                 | |               | |
 | |                 | |               | |        | |                 | |               | |     | |                 | |               | |
 | |                 | |               | |        | |                 | |               | |     | |                 | |               | |
 | |                 | |               | |        | |                 | |               | |     | |                 | |               | |
 | |                 | |               | |        | |                 | |               | |     | |                 | |               | |
 | +-----------------+ +---------------+ |        | +-----------------+ +---------------+ |     | +-----------------+ +---------------+ |
 +---------------------------------------+        +---------------------------------------+     +---------------------------------------+
```