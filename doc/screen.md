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
- `status` => 実装した ✅
- `branch` => 実装した ✅
- `log` => 実装した ✅
- `reflog` => まだ。🚸
- `stash` => まだ。🚸
- `diff` => 実装した ✅

### tig
- `m view-main           Show main view` => 実質log view ✅
- `d view-diff           Show diff view` => 実装した ✅
- `l view-log            Show log view` => 使わない(main viewで十分) ⛔
- `t view-tree           Show tree view` => エクスプローラーっぽい。編集がメインではないので不要⛔
- `f view-blob           Show blob view` => ファイルをそのまま閲覧できる🚸
- `b view-blame          Show blame view` => ファイルにblameを表示。編集がメインではないので不要⛔
- `r view-refs           Show refs view` => refsというかbranch view✅
- `s view-status         Show status view` => 実装した ✅
- `c view-stage          Show stage view` => 操作方法がわからないけどこれは実装した ✅
- `y view-stash          Show stash view` => まだ。🚸
- `g view-grep           Show grep view` => fzfが使えるのでいらない。grepしたいならgrepで。⛔
- `p view-pager          Show pager view` => よくわからないのでいらない ⛔
- `h view-help           Show help view` => まだ。🚸

### forgit
- `git add(ga)` => 実装した ✅
- `git log(glo)` => 実装した ✅
- `gitignore(gi)` => 作っても二番煎じ以下なのでいらない⛔
- `git diff(gd)` => 実装した ✅
- `git reset HEAD <file>(grh)` => 実装した ✅
- `git checkout <file>(gcf)` => 実装した ✅
- `git stash(gss)` => まだ。🚸
- `git clean(gclean)` => いるか？🚸
- `git cherry-pick(gcp)` => いるか？🚸
- `git rebase -i(grb)` => いるか？🚸

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