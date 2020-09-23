# Libvips for Sharp

## Description

Repackaging of Libvips for Sharp project on Linux-x64 (centos) with support of SVG, JPEG (via mozjpeg), PNG, WEBP, GIF image format.

## Build

```
docker build -t vips-dev-linux-x64
```

### Usage

After the build, fetch the result in the `packaging` directory of the image:

```
./build.sh
```

or

```
docker run -it -v $PWD:/local vips-dev-linux-x64 bash
cp /packaging/* /local
```

Publish them under HTTP on the correct folder [expected by Sharp](https://sharp.pixelplumbing.com/install#custom-prebuilt-binaries)
```
mkdir v<VERSION>
cp *.tar.br v<VERSION>/libvips-<VERSION>-linux-x64.tar.br
http-server -p 8080
```

Before installing Sharp depency with npm override the `sharp_libvips_binary_host` env to the destination where you have put your libvips.

With npm config option:
```
npm config set sharp_libvips_binary_host "http://localhost:8080/"
# sometimes a cache cleaning is necessary before the install
rm -rf ~/.npm/_libvips
npm install sharp
```

Or with environment variable:

```
npm_config_sharp_libvips_binary_host="http://localhost:8080/" \
npm install sharp
```

## Licences

These scripts are licensed under the terms of the [Apache 2.0 Licence](LICENSE).

The shared libraries contained in the tarballs are distributed under
the terms of [various licences](THIRD-PARTY-NOTICES.md), all of which
are compatible with the Apache 2.0 Licence.
