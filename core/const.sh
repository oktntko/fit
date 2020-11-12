#!/usr/bin/env bash
# shellcheck disable=2155

if [ -z "$COLOR_SUPPORT" ]; then
  export readonly COLOR_SUPPORT="YES"

  export readonly DARK_GRAY="$(tput setaf 0)"
  export readonly RED="$(tput setaf 1)"
  export readonly GREEN="$(tput setaf 2)"
  export readonly YELLOW="$(tput setaf 3)"
  export readonly BLUE="$(tput setaf 4)"
  export readonly MAGENTA="$(tput setaf 5)"
  export readonly CYAN="$(tput setaf 6)"
  export readonly WHITE="$(tput setaf 7)"
  export readonly GRAY="$(tput setaf 8)"
  export readonly BOLD="$(tput bold)"
  export readonly UNDERLINE="$(tput sgr 0 1)"
  export readonly INVERT="$(tput sgr 1 0)"
  export readonly NORMAL="$(tput sgr0)"
fi
