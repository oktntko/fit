# awk

awk は入力として受け取った文字列に対して、
フィールド区切り文字やレコード区切り文字を指定して
「列」に対する処理を行うためのコマンドです。

### hoge.txt

```
1 2 3
4 5 6
7 8 9
A B C
D E F
G H I
```

## \$0 は渡された文字列すべて

```
❯ cat hoge.txt | awk '{ print $0 }'
1 2 3
4 5 6
7 8 9
A B C
D E F
G H I
```

## \$1 は１つ目の要素

```
❯ cat hoge.txt | awk '{ print $1 }'
1
4
7
A
D
G
```

## \$2 は１つ目の要素

```
❯ cat hoge.txt | awk '{ print $2 }'
2
5
8
B
E
H
```

## 複数要素の出力

```
❯ cat hoge.txt | awk '{ print $1,$2 }'
1 2
4 5
7 8
A B
D E
G H
```

### fuga.txt

```
1,2,3
4,5,6
7,8,9
A,B,C
D,E,F
G,H,I
```

## -F 区切り文字の指定

```
❯ cat fuga.txt | awk '{ print $1 }'
1,2,3
4,5,6
7,8,9
A,B,C
D,E,F
G,H,I
```

## -F 区切り文字の指定

```
❯ cat fuga.txt | awk -F '[,]' '{ print $1 }'
1
4
7
A
D
G
```

## OFS

「OFS」は、Output Field Separator の略で、awk の組み込み変数であり、「出力のフィールド区切り文字」を指定します。
「-v」 は variable(変数)を指定する、という意味のオプションです。

```
❯ cat fuga.txt | awk -F '[,]' -v 'OFS=#' '{ print $1,$2 }'
1#2
4#5
7#8
A#B
D#E
G#H
```

## RS

RS は Record Separator の略で、awk の組み込み変数です。
「入力のレコード区切り文字」を指定、下記では「/」を指定します。

```
❯ echo 1:2/3:4 |awk -F'[:]' -v 'RS=/' '{print $1}'
1
3
❯ echo 1:2/3:4 |awk -F'[:]' -v 'RS=/' '{print $1,$2}'
1 2
3 4
# フィールド区切り文字とレコード区切り文字で同じ文字がある場合、レコード区切り文字が優先されます
❯ echo 1:2/3:4 |awk -F'[:/]' -v 'RS=/' '{print $1,$2}'
1 2
3 4
```

## ORS

「ORS」は、Output Record Separator の略で、awk の組み込み変数であり、「出力のレコード区切り文字」を指定します。

```
❯ echo 1:2/3:4 |awk -F'[:/]' -v 'RS=/' -v 'ORS=This is ORS' '{print $1,$2}'
1 2This is ORS3 4
```

## \$NF

最終フィールドを取り出す変数として\$NF が用意されています。

```
❯ echo 1:2/3:4 |awk -F'[:/]' '{print $NF}'
4

❯ echo 1:2/3:4 |awk -F'[:/]' '{print $NF-1}'
3
```

## まとめ

|                | オプション    | デフォルト |
| -------------- | ------------- | ---------- |
| 入力列の区切り | -F '[hoge]'   | スペース   |
| 出力列の区切り | -v 'OFS=hoge' | スペース   |
| 入力行の区切り | -v 'RS=hoge'  | \n         |
| 出力行の区切り | -v 'ORS=hoge' | \n         |
