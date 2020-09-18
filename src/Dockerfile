FROM centos:7

# Create container suitable for building libvips for linux-x64

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:/opt/rh/devtoolset-9/root/usr/bin:$PATH"

# Build dependencies
RUN \
  yum update -y && \
  yum install -y epel-release centos-release-scl && \
  yum group install -y "Development Tools" && \
  yum install -y --setopt=tsflags=nodocs \
  advancecomp \
  brotli \
  cmake3 \
  devtoolset-9-gcc \
  devtoolset-9-gcc-c++ \
  glib2-devel \
  gobject-introspection-devel \
  gperf \
  gtk-doc \
  jq \
  nasm \
  ninja-build \
  prelink \
  python3 \
  && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
  --no-modify-path \
  --profile minimal \
  && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  pip3 install meson

# Compiler settings
ENV \
  FLAGS="-O3 -fPIC" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/

# Environment / working directories
ENV \
  DEPS="/deps" \
  TARGET="/target" \
  PACKAGE="/packaging" \
  ROOT="/root" \
  VIPS_CPP_DEP="libvips-cpp.so.42"

RUN mkdir ${DEPS} && \
  mkdir ${TARGET}

# Common build paths and flags
ENV \
  PKG_CONFIG_LIBDIR="${TARGET}/lib/pkgconfig" \
  PATH="${PATH}:${TARGET}/bin" \
  CPATH="${TARGET}/include" \
  LIBRARY_PATH="${TARGET}/lib" \
  LD_LIBRARY_PATH="${TARGET}/lib" \
  CFLAGS="${FLAGS}" \
  CXXFLAGS="${FLAGS}" \
  LDFLAGS="-L${TARGET}/lib"

# On Linux, we need to create a relocatable library
# Note: this is handled for macOS using the `install_name_tool` (see below)
ENV LDFLAGS+=" -Wl,-rpath='\$\$ORIGIN/'"

# Run as many parallel jobs as there are available CPU cores
ENV MAKEFLAGS="-j8"

# Optimise Rust code for binary size
ENV \
  CARGO_PROFILE_RELEASE_DEBUG="false" \
  CARGO_PROFILE_RELEASE_CODEGEN_UNITS="1" \
  CARGO_PROFILE_RELEASE_INCREMENTAL="false" \
  CARGO_PROFILE_RELEASE_LTO="true" \
  CARGO_PROFILE_RELEASE_OPT_LEVEL="s" \
  CARGO_PROFILE_RELEASE_PANIC="abort"

ENV \
  VERSION_VIPS=8.10.1 \
  VERSION_ZLIB=1.2.11 \
  VERSION_FFI=3.3 \
  VERSION_GLIB=2.66.0 \
  VERSION_XML2=2.9.10 \
  VERSION_GSF=1.14.47 \
  VERSION_EXIF=0.6.22 \
  VERSION_LCMS2=2.11 \
  VERSION_PNG16=1.6.37 \
  VERSION_SPNG=0.6.1 \
  VERSION_WEBP=1.1.0 \
  VERSION_ORC=0.4.32 \
  VERSION_GDKPIXBUF=2.40.0 \
  VERSION_FREETYPE=2.10.2 \
  VERSION_EXPAT=2.2.9 \
  VERSION_FONTCONFIG=2.13.92 \
  VERSION_HARFBUZZ=2.7.2 \
  VERSION_PIXMAN=0.40.0 \
  VERSION_CAIRO=1.16.0 \
  VERSION_FRIBIDI=1.0.10 \
  VERSION_PANGO=1.46.1 \
  VERSION_SVG=2.50.0 \
  VERSION_GIF=5.1.4 \
  VERSION_MOZJPEG=3.3.1 \
  # version without minor patch
  HIGH_VERSION_GLIB=2.66 \
  HIGH_VERSION_GSF=1.14 \
  HIGH_VERSION_GDKPIXBUF=2.40 \
  HIGH_VERSION_PANGO=1.46 \
  HIGH_VERSION_SVG=2.50

RUN mkdir ${DEPS}/zlib && \
  curl -Ls https://zlib.net/zlib-${VERSION_ZLIB}.tar.xz | tar xJC ${DEPS}/zlib --strip-components=1 && \
  cd ${DEPS}/zlib && \
  ./configure --prefix=${TARGET} --uname=linux --static && \
  make install

RUN mkdir ${DEPS}/ffi && \
  curl -Ls https://github.com/libffi/libffi/releases/download/v${VERSION_FFI}/libffi-${VERSION_FFI}.tar.gz | tar xzC ${DEPS}/ffi --strip-components=1 && \
  cd ${DEPS}/ffi && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --disable-builddir --disable-multi-os-directory --disable-raw-api && \
  make install-strip

RUN mkdir ${DEPS}/glib && \
  curl -Lks https://download.gnome.org/sources/glib/${HIGH_VERSION_GLIB}/glib-${VERSION_GLIB}.tar.xz | tar xJC ${DEPS}/glib --strip-components=1 && \
  cd ${DEPS}/glib && \
  # Disable tests
  sed -i'.bak' "/build_tests =/ s/= .*/= false/" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dinternal_pcre=true -Dinstalled_tests=false -Dlibmount=disabled && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/xml2 && \
  curl -Ls http://xmlsoft.org/sources/libxml2-${VERSION_XML2}.tar.gz | tar xzC ${DEPS}/xml2 --strip-components=1 && \
  cd ${DEPS}/xml2 && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --without-python --without-debug --without-docbook --without-ftp --without-html --without-legacy \
  --without-push --without-schematron --without-lzma --with-zlib=${TARGET} && \
  make install-strip

RUN mkdir ${DEPS}/gsf && \
  curl -Lks https://download.gnome.org/sources/libgsf/${HIGH_VERSION_GSF}/libgsf-${VERSION_GSF}.tar.xz | tar xJC ${DEPS}/gsf --strip-components=1 && \
  cd ${DEPS}/gsf && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --without-bz2 --without-gdk-pixbuf --with-zlib=${TARGET} && \
  make install-strip

RUN mkdir ${DEPS}/exif && \
  curl -Ls https://github.com/libexif/libexif/releases/download/libexif-${VERSION_EXIF//./_}-release/libexif-${VERSION_EXIF}.tar.xz | tar xJC ${DEPS}/exif --strip-components=1 && \
  cd ${DEPS}/exif && \
  autoreconf -fiv && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking && \
  make install-strip

RUN mkdir ${DEPS}/lcms2 && \
  curl -Ls https://downloads.sourceforge.net/project/lcms/lcms/${VERSION_LCMS2}/lcms2-${VERSION_LCMS2}.tar.gz | tar xzC ${DEPS}/lcms2 --strip-components=1 && \
  cd ${DEPS}/lcms2 && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking && \
  make install-strip

RUN mkdir ${DEPS}/mozjpeg && \
  curl -Ls https://github.com/mozilla/mozjpeg/archive/v${VERSION_MOZJPEG}.tar.gz | tar xzC ${DEPS}/mozjpeg --strip-components=1 && \
  cd ${DEPS}/mozjpeg && \
  aclocal && autoconf && autoheader && libtoolize && automake --add-missing && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking --with-jpeg8 && \
  make install-strip && \
  cp jpegint.h ${TARGET}/include/jpegint.h

RUN mkdir ${DEPS}/png16 && \
  curl -Ls https://sourceforge.mirrorservice.org/l/li/libpng/libpng16/${VERSION_PNG16}/libpng-${VERSION_PNG16}.tar.xz | tar xJC ${DEPS}/png16 --strip-components=1 && \
  cd ${DEPS}/png16 && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking && \
  make install-strip

RUN mkdir ${DEPS}/spng && \
  curl -Ls https://github.com/randy408/libspng/archive/v${VERSION_SPNG}.tar.gz | tar xzC ${DEPS}/spng --strip-components=1 && \
  cd ${DEPS}/spng && \
  meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dstatic_zlib=true && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/webp && \
  curl -Ls https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${VERSION_WEBP}.tar.gz | tar xzC ${DEPS}/webp --strip-components=1 && \
  cd ${DEPS}/webp && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --disable-neon --enable-libwebpmux --enable-libwebpdemux && \
  make install-strip

RUN mkdir ${DEPS}/orc && \
  curl -Ls https://gstreamer.freedesktop.org/data/src/orc/orc-${VERSION_ORC}.tar.xz | tar xJC ${DEPS}/orc --strip-components=1 && \
  cd ${DEPS}/orc && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dorc-test=disabled -Dbenchmarks=disabled -Dexamples=disabled -Dgtk_doc=disabled -Dtests=disabled -Dtools=disabled && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/gdkpixbuf && \
  curl -Lks https://download.gnome.org/sources/gdk-pixbuf/${HIGH_VERSION_GDKPIXBUF}/gdk-pixbuf-${VERSION_GDKPIXBUF}.tar.xz | tar xJC ${DEPS}/gdkpixbuf --strip-components=1 && \
  cd ${DEPS}/gdkpixbuf && \
  # Disable tests and thumbnailer
  sed -i'.bak' "/subdir('tests')/{N;d;}" meson.build && \
  # Disable the built-in loaders for BMP, GIF, ICO, PNM, XPM, XBM, TGA, ICNS and QTIF
  sed -i'.bak' "/\[ 'bmp'/{N;N;N;d;}" gdk-pixbuf/meson.build && \
  sed -i'.bak' "/\[ 'pnm'/d" gdk-pixbuf/meson.build && \
  sed -i'.bak' "/\[ 'xpm'/{N;N;N;N;N;d;}" gdk-pixbuf/meson.build && \
  # Ensure meson can find libjpeg when cross-compiling
  sed -i'.bak' "s/has_header('jpeglib.h')/has_header('jpeglib.h', args: '-I\/target\/include')/g" meson.build && \
  sed -i'.bak' "s/cc.find_library('jpeg'/dependency('libjpeg'/g" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dtiff=false -Dx11=false -Dgir=false -Dinstalled_tests=false -Dgio_sniffing=false -Dman=false -Dbuiltin_loaders=png,jpeg && \
  ninja -C _build && \
  ninja -C _build install && \
  # Include libjpeg and libpng as a dependency of gdk-pixbuf, see: https://gitlab.gnome.org/GNOME/gdk-pixbuf/merge_requests/50
  sed -i'.bak' "s/^\(Requires:.*\)/\1 libjpeg, libpng16/" ${TARGET}/lib/pkgconfig/gdk-pixbuf-2.0.pc

RUN mkdir ${DEPS}/freetype && \
  curl -Ls https://download.savannah.gnu.org/releases/freetype/freetype-${VERSION_FREETYPE}.tar.xz | tar xJC ${DEPS}/freetype --strip-components=1 && \
  cd ${DEPS}/freetype && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --without-bzip2 --without-png && \
  make install

RUN mkdir ${DEPS}/expat && \
  curl -Ls https://github.com/libexpat/libexpat/releases/download/R_${VERSION_EXPAT//./_}/expat-${VERSION_EXPAT}.tar.xz | tar xJC ${DEPS}/expat --strip-components=1 && \
  cd ${DEPS}/expat && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared \
  --disable-dependency-tracking --without-xmlwf --without-docbook --without-getrandom --without-sys-getrandom && \
  make install

RUN mkdir ${DEPS}/fontconfig && \
  curl -Ls https://www.freedesktop.org/software/fontconfig/release/fontconfig-${VERSION_FONTCONFIG}.tar.xz | tar xJC ${DEPS}/fontconfig --strip-components=1 && \
  cd ${DEPS}/fontconfig && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --with-expat-includes=${TARGET}/include --with-expat-lib=${TARGET}/lib --sysconfdir=/etc \
  --disable-docs && \
  make install-strip

RUN mkdir ${DEPS}/harfbuzz && \
  curl -Ls https://github.com/harfbuzz/harfbuzz/archive/${VERSION_HARFBUZZ}.tar.gz | tar xzC ${DEPS}/harfbuzz --strip-components=1 && \
  cd ${DEPS}/harfbuzz && \
  # Disable utils
  sed -i'.bak' "/subdir('util')/d" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dicu=disabled -Dtests=disabled -Dintrospection=disabled -Ddocs=disabled -Dbenchmark=disabled && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/pixman && \
  curl -Ls https://cairographics.org/releases/pixman-${VERSION_PIXMAN}.tar.gz | tar xzC ${DEPS}/pixman --strip-components=1 && \
  cd ${DEPS}/pixman && \
  # Disable tests and demos
  sed -i'.bak' "/subdir('test')/{N;d;}" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dlibpng=disabled -Diwmmxt=disabled -Dgtk=disabled -Dopenmp=disabled && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/cairo && \
  curl -Ls https://cairographics.org/releases/cairo-${VERSION_CAIRO}.tar.xz | tar xJC ${DEPS}/cairo --strip-components=1 && \
  cd ${DEPS}/cairo && \
  sed -i'.bak' "s/^\(Libs:.*\)/\1 @CAIRO_NONPKGCONFIG_LIBS@/" src/cairo.pc.in && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --disable-xlib --disable-xcb --disable-win32 --disable-egl --disable-glx --disable-wgl --disable-ps \
  --disable-trace --disable-interpreter --disable-quartz \
  LIBS="-lpixman-1 -lfreetype" && \
  make install-strip

RUN mkdir ${DEPS}/fribidi && \
  curl -Ls https://github.com/fribidi/fribidi/releases/download/v${VERSION_FRIBIDI}/fribidi-${VERSION_FRIBIDI}.tar.xz | tar xJC ${DEPS}/fribidi --strip-components=1 && \
  cd ${DEPS}/fribidi && \
  # Disable tests
  sed -i'.bak' "/subdir('test')/d" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Ddocs=false && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/pango && \
  curl -Ls https://download.gnome.org/sources/pango/${HIGH_VERSION_PANGO}/pango-${VERSION_PANGO}.tar.xz | tar xJC ${DEPS}/pango --strip-components=1 && \
  cd ${DEPS}/pango && \
  # Disable utils, examples, tests and tools
  sed -i'.bak' "/subdir('utils')/{N;N;N;d;}" meson.build && \
  LDFLAGS=${LDFLAGS/\$/} meson setup _build --default-library=static --buildtype=release --strip --prefix=${TARGET} ${MESON} \
  -Dgtk_doc=false -Dintrospection=false -Duse_fontconfig=true && \
  ninja -C _build && \
  ninja -C _build install

RUN mkdir ${DEPS}/svg && \
  curl -Ls https://download.gnome.org/sources/librsvg/${HIGH_VERSION_SVG}/librsvg-${VERSION_SVG}.tar.xz | tar xJC ${DEPS}/svg --strip-components=1 && \
  cd ${DEPS}/svg && \
  sed -i'.bak' "s/^\(Requires:.*\)/\1 cairo-gobject pangocairo/" librsvg.pc.in && \
  # Do not include debugging symbols
  sed -i'.bak' "/debug =/ s/= .*/= false/" Cargo.toml && \
  # LTO optimization does not work for staticlib+rlib compilation
  sed -i'.bak' "s/, \"rlib\"//" librsvg/Cargo.toml && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking \
  --disable-introspection --disable-tools --disable-pixbuf-loader && \
  make install-strip

RUN mkdir ${DEPS}/gif && \
  curl -Ls https://sourceforge.mirrorservice.org/g/gi/giflib/giflib-${VERSION_GIF}.tar.gz | tar xzC ${DEPS}/gif --strip-components=1 && \
  cd ${DEPS}/gif && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-static --disable-shared --disable-dependency-tracking && \
  make install-strip

RUN mkdir ${DEPS}/vips && \
  curl -Ls https://github.com/libvips/libvips/releases/download/v${VERSION_VIPS}/vips-${VERSION_VIPS}.tar.gz | tar xzC ${DEPS}/vips --strip-components=1 && \
  cd ${DEPS}/vips && \
  ./configure --host=${CHOST} --prefix=${TARGET} --enable-shared --disable-static --disable-dependency-tracking \
  --disable-debug --disable-deprecated --disable-introspection --without-analyze --without-cfitsio --without-fftw \
  --without-heif --without-imagequant --without-magick --without-matio --without-nifti --without-OpenEXR \
  --without-openslide --without-pdfium --without-poppler --without-ppm --without-radiance --without-tiff \
  --with-jpeg-includes=${DEPS}/mozjpeg/include --with-jpeg-libraries=${DEPS}/mozjpeg/lib64 \
  LDFLAGS="$LDFLAGS -Wl,-Bsymbolic-functions" && \
  # https://docs.fedoraproject.org/en-US/packaging-guidelines/#_removing_rpath
  sed -i'.bak' 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool && \
  make install-strip

# Cleanup
RUN rm -rf ${TARGET}/lib/{pkgconfig,.libs,*.la,cmake} && \
  mkdir ${TARGET}/lib-filtered && \
  mv ${TARGET}/lib/glib-2.0 ${TARGET}/lib-filtered

# Pack only the relevant libraries
COPY copydeps.sh /root/

RUN cd ${TARGET}/lib && \
  source /root/copydeps.sh && \
  copydeps ${VIPS_CPP_DEP} ${TARGET}/lib-filtered

ENV PLATFORM=linux-x64
# Create JSON file of version numbers
RUN cd ${TARGET} && \
  printf "{\n\
  \"cairo\": \"${VERSION_CAIRO}\",\n\
  \"exif\": \"${VERSION_EXIF}\",\n\
  \"expat\": \"${VERSION_EXPAT}\",\n\
  \"ffi\": \"${VERSION_FFI}\",\n\
  \"fontconfig\": \"${VERSION_FONTCONFIG}\",\n\
  \"freetype\": \"${VERSION_FREETYPE}\",\n\
  \"fribidi\": \"${VERSION_FRIBIDI}\",\n\
  \"gdkpixbuf\": \"${VERSION_GDKPIXBUF}\",\n\
  \"gif\": \"${VERSION_GIF}\",\n\
  \"glib\": \"${VERSION_GLIB}\",\n\
  \"gsf\": \"${VERSION_GSF}\",\n\
  \"harfbuzz\": \"${VERSION_HARFBUZZ}\",\n\
  \"lcms\": \"${VERSION_LCMS2}\",\n\
  \"orc\": \"${VERSION_ORC}\",\n\
  \"pango\": \"${VERSION_PANGO}\",\n\
  \"pixman\": \"${VERSION_PIXMAN}\",\n\
  \"png\": \"${VERSION_PNG16}\",\n\
  \"svg\": \"${VERSION_SVG}\",\n\
  \"spng\": \"${VERSION_SPNG}\",\n\
  \"vips\": \"${VERSION_VIPS}\",\n\
  \"webp\": \"${VERSION_WEBP}\",\n\
  \"xml\": \"${VERSION_XML2}\",\n\
  \"zlib\": \"${VERSION_ZLIB}\",\n\
  \"mozjpeg\": \"${VERSION_MOZJPEG}\"\n\
  }" >versions.json && \
  printf "\"${PLATFORM}\"" >platform.json && \
  # Add third-party notices
  curl -Os https://raw.githubusercontent.com/lovell/sharp-libvips/master/THIRD-PARTY-NOTICES.md

# Create the tarball
RUN cd ${TARGET} && \
  rm -rf lib && \
  mv lib-filtered lib && \
  mkdir ${PACKAGE} && \
  tar chzf ${PACKAGE}/libvips-${VERSION_VIPS}-${PLATFORM}.tar.gz \
  include \
  lib \
  *.json \
  THIRD-PARTY-NOTICES.md && \
  # Recompress using AdvanceCOMP, ~5% smaller
  advdef --recompress --shrink-insane ${PACKAGE}/libvips-${VERSION_VIPS}-${PLATFORM}.tar.gz && \
  # Recompress using Brotli, ~15% smaller
  gunzip -c ${PACKAGE}/libvips-${VERSION_VIPS}-${PLATFORM}.tar.gz | brotli -f -o ${PACKAGE}/libvips-${VERSION_VIPS}-${PLATFORM}.tar.br && \
  # Allow tarballs to be read outside container
  chmod 644 ${PACKAGE}/libvips-${VERSION_VIPS}-${PLATFORM}.tar.*
