#!/usr/bin/env bash

fit::core::log() {
  git log \
    --graph \
    --color=always \
    --pretty="[%C(yellow)%h%Creset]%C(auto)%d%Creset %s %C(cyan bold)%an%Creset (%C(magenta)%ad%Creset)" \
    --date=format:"%Y-%m-%d" \
    "${1:-"--all"}"
}

fit::core::log::extract() {
  echo "$*" | grep -Eo '\[[a-f0-9]{7}\]'
}

fit::log::list::extract() {
  echo "$@" | grep -Eo '[a-f0-9]+' | head -1
}
