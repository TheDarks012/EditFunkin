#!/bin/sh
echo -ne '\033c\033]0;EditFunkin\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/EditFunkin.x86_64" "$@"
