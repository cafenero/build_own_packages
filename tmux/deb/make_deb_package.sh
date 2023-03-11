#!/bin/bash -e

# Build tmux
sudo apt install -y libevent-dev libncurses-dev
git clone https://github.com/tmux/tmux.git
cd tmux
git checkout 3.3
sh autogen.sh
./configure
make
cd ..

# Prepare files
rm -rf tmux-work-dir
mkdir -p tmux-work-dir/DEBIAN
mkdir -p tmux-work-dir/usr/local/bin/
mkdir -p tmux-work-dir/usr/local/share/man/

cp tmux/tmux   tmux-work-dir/usr/local/bin/
cp tmux/tmux.1 tmux-work-dir/usr/local/share/man/
# chmod 755    tmux-work-dir/usr/local/bin/tmux
md5sum tmux-work-dir/usr/local/bin/tmux > tmux-work-dir/DEBIAN/md5sums
ISIZE=$(du -ks tmux-work-dir/usr | awk '{print $1}')
VERSION=3.3-$(date "+%Y-%m-%d-%H-%M")
cat << EOS > tmux-work-dir/DEBIAN/control
Package: tmux
Version: $VERSION
Architecture: amd64
Maintainer: self build
Installed-Size: $ISIZE
Section: devel
Priority: optional
Homepage: http://www.example.com/
Description: tmux 3.3 for my own build
EOS

# build deb package
fakeroot dpkg-deb --build tmux-work-dir .
