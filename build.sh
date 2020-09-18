#!/usr/bin/env bash
set -e

# Is docker available?
if ! [ -x "$(command -v docker)" ]; then
  echo "Please install docker"
  exit 1
fi

echo "Building libvips for linux-x64..."
docker pull centos:7
docker build -t vips-dev-linux-x64 src
docker run --rm -v $PWD:/local vips-dev-linux-x64 bash -c "cp /packaging/* /local"

# Display checksums
sha256sum *.tar.{br,gz}
