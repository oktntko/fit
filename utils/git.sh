#!/usr/bin/env bash
fit::utils::is-inside-work-tree() {
  git rev-parse --is-inside-work-tree >/dev/null
}
