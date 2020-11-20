#!/usr/bin/env bash

fit::utils::edit-file() {
  ! fit::utils::is-valid-file "$1" && return

  eval "${FIT_EDITOR} ${1}  </dev/tty >/dev/tty"
}

fit::utils::remove-file() {
  ! fit::utils::is-valid-file "$1" && return

  rm "$1"
}