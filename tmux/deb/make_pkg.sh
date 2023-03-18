#!/bin/bash -e

if [ $# -ne 2 ]; then
  echo "specify tmux verion and arch!"
  echo "ex: ./make_deb_package.sh 3.3 amd64"
  echo "ex: ./make_deb_package.sh 3.3 arm64"
  exit 1
fi
TMUX_VERSION=$1
DEB_ARCH=$2

# Cleanup
WORK_DIR=work-dir
if [[ -d $WORK_DIR ]]; then
    rm -rf $WORK_DIR
fi
mkdir work-dir
cd $WORK_DIR

# Build tmux
if [ "$EUID" -eq 0 ]; then
         apt install -y build-essential libevent-dev libncurses-dev
else
    sudo apt install -y build-essential libevent-dev libncurses-dev
fi
git clone https://github.com/tmux/tmux.git
cd tmux
git checkout "${TMUX_VERSION}"
sh autogen.sh
./configure
make
cd ..

# Prepare files
PKG_WORK_DIR=pkg-work-dir
mkdir -p       $PKG_WORK_DIR/DEBIAN
mkdir -p       $PKG_WORK_DIR/usr/local/bin/
mkdir -p       $PKG_WORK_DIR/usr/local/share/man/
cp tmux/tmux   $PKG_WORK_DIR/usr/local/bin/
cp tmux/tmux.1 $PKG_WORK_DIR/usr/local/share/man/
md5sum         $PKG_WORK_DIR/usr/local/bin/tmux > $PKG_WORK_DIR/DEBIAN/md5sums

# Set params
ISIZE=$(du -ks $PKG_WORK_DIR/usr | awk '{print $1}')
VERSION=$TMUX_VERSION-$(date "+%Y-%m-%d-%H-%M")
cat << EOS > $PKG_WORK_DIR/DEBIAN/control
Package: tmux
Version: $VERSION
Architecture: $DEB_ARCH
Maintainer: self build
Installed-Size: $ISIZE
Section: admin
Priority: optional
Homepage: https://github.com/cafenero/build_own_packages
Description: tmux $TMUX_VERSION for my own build
EOS

cat << EOS >> $PKG_WORK_DIR/DEBIAN/copyright
ISC license
EOS

# Build deb package
fakeroot dpkg-deb --build $PKG_WORK_DIR ..
