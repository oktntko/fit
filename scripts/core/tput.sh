#!/usr/bin/env bash
# shellcheck disable=2155

# 文字色を指定する
# tput setaf 色番号
# 背景色を指定する
# tput setab 色番号
export readonly BLACK="$(tput setaf 0)"
export readonly RED="$(tput setaf 1)"
export readonly GREEN="$(tput setaf 2)"
export readonly YELLOW="$(tput setaf 3)"
export readonly BLUE="$(tput setaf 4)"
export readonly MAGENTA="$(tput setaf 5)"
export readonly CYAN="$(tput setaf 6)"
export readonly WHITE="$(tput setaf 7)"
export readonly GRAY="$(tput setaf 8)"

export readonly B_BLACK="$(tput setab 0)"
export readonly B_RED="$(tput setab 1)"
export readonly B_GREEN="$(tput setab 2)"
export readonly B_YELLOW="$(tput setab 3)"
export readonly B_BLUE="$(tput setab 4)"
export readonly B_MAGENTA="$(tput setab 5)"
export readonly B_CYAN="$(tput setab 6)"
export readonly B_WHITE="$(tput setab 7)"
export readonly B_GRAY="$(tput setab 8)"

export readonly BOLD="$(tput bold)"
export readonly DIM="$(tput dim)"
export readonly S_UNDERLINE="$(tput smul)"
export readonly E_UNDERLINE="$(tput rmul)"
export readonly REVERSE="$(tput rev)"
export readonly S_STANDOUT="$(tput smso)"
export readonly E_STANDOUT="$(tput rmso)"
export readonly NORMAL="$(tput sgr0)"
