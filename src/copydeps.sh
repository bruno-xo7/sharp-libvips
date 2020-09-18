#!/usr/bin/env bash
set -e

# Pack only the relevant libraries
function copydeps {
  local base=$1
  local dest_dir=$2

  cp -L $base $dest_dir/$base
  chmod 644 $dest_dir/$base

  local dependencies=$(readelf -d $base | grep NEEDED | awk '{ print $5 }' | tr -d '[]')

  for dep in $dependencies; do
    base_dep=$(basename $dep)

    [ ! -f "$PWD/$base_dep" ] && echo "$base_dep does not exist in $PWD" && continue
    echo "$base depends on $base_dep"

    if [ ! -f "$dest_dir/$base_dep" ]; then
      # Call this function (recursive) on each dependency of this library
      copydeps $base_dep $dest_dir
    fi
  done;
}
