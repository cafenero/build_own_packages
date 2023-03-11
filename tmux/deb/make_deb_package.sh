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
if [[ -d tmux ]]; then
    rm -rf tmux
fi
if [[ -d tmux-work-dir ]]; then
    rm -rf tmux-work-dir
fi

# Build tmux
sudo apt install -y libevent-dev libncurses-dev
git clone https://github.com/tmux/tmux.git
cd tmux
git checkout "${TMUX_VERSION}"
sh autogen.sh
./configure
make
cd ..

# Prepare files
mkdir -p tmux-work-dir/DEBIAN
mkdir -p tmux-work-dir/usr/local/bin/
mkdir -p tmux-work-dir/usr/local/share/man/

cp tmux/tmux   tmux-work-dir/usr/local/bin/
cp tmux/tmux.1 tmux-work-dir/usr/local/share/man/
md5sum tmux-work-dir/usr/local/bin/tmux > tmux-work-dir/DEBIAN/md5sums
ISIZE=$(du -ks tmux-work-dir/usr | awk '{print $1}')
VERSION=$TMUX_VERSION-$(date "+%Y-%m-%d-%H-%M")
cat << EOS > tmux-work-dir/DEBIAN/control
Package: tmux
Version: $VERSION
Architecture: $DEB_ARCH
Maintainer: self build
Installed-Size: $ISIZE
Section: devel
Priority: optional
Homepage: http://www.example.com/
Description: tmux $TMUX_VERSION for my own build
EOS

# Build deb package
fakeroot dpkg-deb --build tmux-work-dir .
