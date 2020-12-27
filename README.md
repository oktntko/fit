<h1 align="center">fit</h1>

`fit` is a command line tool that helps you use git.  

# Description
`fit` is a CLI tool that helps you work with git.  
The concept is to be able to use git commands as they are in `fit`.  

**_DEMO:_**

[![asciicast](https://asciinema.org/a/gckUiq3HaLLM2dwmwkAuDLBdY.svg)](https://asciinema.org/a/gckUiq3HaLLM2dwmwkAuDLBdY)

# Features
- You can continue to use git options.  
- You can check the key binding immediately.  

# Requirement
- [`fzf`](https://github.com/junegunn/fzf)

# 📥 Installation
```zsh
# for zplug
zplug "oktntko/fit", as:command, use:fit
```

# Usage
## 1. fit expands git actions shown below
- git commit(status/add/restore)
- git branch
- git log
- git diff
- git stash

## 2. use fit like git 
```
git status -> fit status
git branch -> fit branch
git log -> fit log
git diff -> fit diff
git stash -> fit stash
```

## 3. and more see [wiki](https://github.com/oktntko/fit/wiki)

# Inspired
[`forgit`](https://github.com/wfxr/forgit)
[`git-fuzzy`](https://github.com/bigH/git-fuzzy)
[`tortoiseGit`](https://tortoisegit.org/)

## 📦 Optional dependencies
- [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) or [`delta`](https://github.com/dandavison/delta)
- [`bat`](https://github.com/sharkdp/bat.git)
- [`tree`](https://github.com/nodakai/tree-command)

## 💡 Tips

## Author

@oktntko

## 📃 License

MIT
