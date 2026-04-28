#!/bin/bash
dir="$1"
valid_subdir="staticresources"

if [ "$(ls -A $dir | grep -v "$valid_subdir")" ]; then
  echo "Error: '$dir' is not empty! Please clean the directory. Only two files in '$valid_subdir' are valid and need to stay."
  exit 1
fi
