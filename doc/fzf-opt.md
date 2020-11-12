usage: fzf [options]

使わない　：NO
場合により：OP
デフォルト：DF
考え中　　：TH
意味不明　：FM

  Search

NO  -x, --extended        Extended-search mode
                          (enabled by default; +x or --no-extended to disable)
NO  -e, --exact           Enable Exact-match
NO  --algo=TYPE           Fuzzy matching algorithm: [v1|v2] (default: v2)
OP  -i                    Case-insensitive match (default: smart-case match)
OP  +i                    Case-sensitive match
FM  --literal             Do not normalize latin script letters before matching
OP  -n, --nth=N[,..]      Comma-separated list of field index expressions
                          for limiting search scope. Each can be a non-zero
                          integer or a range expression ([BEGIN]..[END]).
     区切り文字で区切られる文字のどこを検索対象にするか。
     ```
     hoge.txt
     1 2 3
     4 5 6
     7 8 9
     A B C
     D E F
     G H I
     
     ❯ cat hoge.txt | fzf -n 2 --no-mouse
     >        
       6/6
     > 1 2 3
       4 5 6
       7 8 9
       A B C
       D E F
       G H I
     
     > 2        
       1/6
     > 1 2 3
     
     > 3        
       0/6
     
     ❯ cat hoge.txt | fzf -n 2,3 --no-mouse
     >        
       6/6
     > 1 2 3
       4 5 6
       7 8 9
       A B C
       D E F
       G H I
     
     > 2        
       1/6
     > 1 2 3
     
     > 3        
       1/6
     > 1 2 3
     
     > 1        
       0/6
     ```
OP  --with-nth=N[,..]     Transform the presentation of each line using
    検索対象だけを表示する
                          field index expressions
OP  -d, --delimiter=STR   Field delimiter regex (default: AWK-style)
    区切り文字を指定する。デフォルトはスペース
OP  +s, --no-sort         Do not sort the result
OP  --tac                 Reverse the order of the input
FM  --phony               Do not perform search
OP  --tiebreak=CRI[,..]   Comma-separated list of sort criteria to apply
                          when the scores are tied [length|begin|end|index]
                          (default: length)

  Interface
OP  -m, --multi[=MAX]     Enable multi-select with tab/shift-tab
OP  --no-mouse            Disable mouse
OP  --bind=KEYBINDS       Custom key bindings. Refer to the man page.
OP  --cycle               Enable cyclic scroll
FM  --keep-right          Keep the right end of the line visible on overflow
FM  --no-hscroll          Disable horizontal scroll
FM  --hscroll-off=COL     Number of screen columns to keep to the right of the
                          highlighted substring (default: 10)
FM  --filepath-word       Make word-wise movements respect path separators
FM  --jump-labels=CHARS   Label characters for jump and jump-accept

  Layout
    --height=HEIGHT[%]    Display fzf window below the cursor with the given
                          height instead of using fullscreen
    --min-height=HEIGHT   Minimum height when --height is given in percent
                          (default: 10)
    --layout=LAYOUT       Choose layout: [default|reverse|reverse-list]
    --border[=STYLE]      Draw border around the finder
                          [rounded|sharp|horizontal] (default: rounded)
    --margin=MARGIN       Screen margin (TRBL / TB,RL / T,RL,B / T,R,B,L)
    --info=STYLE          Finder info style [default|inline|hidden]
    --prompt=STR          Input prompt (default: '> ')
    --pointer=STR         Pointer to the current line (default: '>')
    --marker=STR          Multi-select marker (default: '>')
    --header=STR          String to print as header
    --header-lines=N      The first N lines of the input are treated as header

  Display
    --ansi                Enable processing of ANSI color codes
    --tabstop=SPACES      Number of spaces for a tab character (default: 8)
    --color=COLSPEC       Base scheme (dark|light|16|bw) and/or custom colors
    --no-bold             Do not use bold text

  History
    --history=FILE        History file
    --history-size=N      Maximum number of history entries (default: 1000)

  Preview
    --preview=COMMAND     Command to preview highlighted line ({})
    --preview-window=OPT  Preview window layout (default: right:50%)
                          [up|down|left|right][:SIZE[%]]
                          [:[no]wrap][:[no]cycle][:[no]hidden]
                          [:rounded|sharp|noborder]
                          [:+SCROLL[-OFFSET]]
                          [:default]

  Scripting
    -q, --query=STR       Start the finder with the given query
    -1, --select-1        Automatically select the only match
    -0, --exit-0          Exit immediately when there's no match
    -f, --filter=STR      Filter mode. Do not start interactive finder.
    --print-query         Print query as the first line
    --expect=KEYS         Comma-separated list of keys to complete fzf
    --read0               Read input delimited by ASCII NUL characters
    --print0              Print output delimited by ASCII NUL characters
    --sync                Synchronous search for multi-staged filtering
    --version             Display version information and exit

  Environment variables
    FZF_DEFAULT_COMMAND   Default command to use when input is tty
    FZF_DEFAULT_OPTS      Default options
                          (e.g. '--layout=reverse --inline-info')