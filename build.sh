#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# load scripts
# --------------------------------------------------------------------------------

shell_files=()

script_dir="$(cd "$(dirname "$(readlink "$0" || echo "$0")")" >/dev/null 2>&1 && pwd)"

while IFS= read -r -d "" file; do
  shell_files+=("$file")
done < <(find "$script_dir" -name "*.sh" -type f -print0)

cat ${shell_files[*]} > "${script_dir}/bin/fit"
