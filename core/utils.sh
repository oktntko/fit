#!/usr/bin/env bash
# quotes mult-word parameters in order to make a command copy-paste with ease
fit::utils::quote-single-param() {
  if [ -z "$1" ] || [[ "$1" = *' '* ]]; then
    if [[ "$1" = *"'"* ]]; then
      echo "\"$1\""
    else
      echo "'$1'"
    fi
  else
    echo "$1"
  fi
}

# quotes a list of params using `"$@"`
# MISSING: support for anything escapable (`\n`, `\t`, etc.?)
# MISSING: support quotes in params (e.g. quoting `'a' "b'd"`)
fit::utils::quote-params() {
  local rest=""
  for arg in "$@"; do
    if [ -z "$rest" ]; then
      printf "%s" "$(fit::utils::quote-single-param "$arg")"
      rest=true
    else
      printf " %s" "$(fit::utils::quote-single-param "$arg")"
    fi
  done
}
