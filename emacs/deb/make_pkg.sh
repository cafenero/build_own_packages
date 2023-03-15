#!/bin/bash -e

if [ $# -ne 2 ]; then
  echo "specify emacs verion and arch!"
  echo "ex: ./make_deb_package.sh 28.2 amd64"
  echo "ex: ./make_deb_package.sh 28.2 arm64"
  exit 1
fi
EMACS_VERSION=$1
DEB_ARCH=$2

# Cleanup
WORK_DIR=work-dir
if [[ -d $WORK_DIR ]]; then
    rm -rf $WORK_DIR
fi
mkdir work-dir
cd $WORK_DIR

# Build emacs
if [ "$EUID" -eq 0 ]; then
         apt install -y automake ncurses-dev texinfo gnutls-dev wget
else
    sudo apt install -y automake ncurses-dev texinfo gnutls-dev wget
fi


wget http://ftp.jaist.ac.jp/pub/GNU/emacs/emacs-"$EMACS_VERSION".tar.gz
tar xf emacs-"$EMACS_VERSION".tar.gz
mv emacs-"$EMACS_VERSION" emacs
cd emacs
./autogen.sh
./configure --without-x
make
cd ..

# Prepare files
PKG_WORK_DIR=pkg-work-dir
rm -rf $PKG_WORK_DIR
mkdir -p                     $PKG_WORK_DIR/DEBIAN
mkdir -p                     $PKG_WORK_DIR/usr/local/bin/
mkdir -p                     $PKG_WORK_DIR/usr/local/share/man/
mkdir -p                     $PKG_WORK_DIR/usr/local/share/emacs/"$EMACS_VERSION"/lisp
cp emacs/lib-src/ctags       $PKG_WORK_DIR/usr/local/bin/
cp emacs/lib-src/ebrowse     $PKG_WORK_DIR/usr/local/bin/
cp emacs/lib-src/emacsclient $PKG_WORK_DIR/usr/local/bin/
cp emacs/lib-src/etags       $PKG_WORK_DIR/usr/local/bin/
cp emacs/src/emacs           $PKG_WORK_DIR/usr/local/bin/
cp -r emacs/lisp             $PKG_WORK_DIR/usr/local/share/emacs/"$EMACS_VERSION"/
cp -r emacs/doc/man/*        $PKG_WORK_DIR/usr/local/share/man/
cp -r emacs/etc/charsets     $PKG_WORK_DIR/usr/local/share/emacs/"$EMACS_VERSION"/
if [[ $DEB_ARCH == "arm64" ]]; then
    mkdir -p                     $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/aarch64-unknown-linux-gnu/
    cp emacs/lib-src/rcs2log     $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/aarch64-unknown-linux-gnu/
    cp emacs/lib-src/hexl        $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/aarch64-unknown-linux-gnu/
    cp emacs/lib-src/movemail    $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/aarch64-unknown-linux-gnu/
else
    mkdir -p                     $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/x86_64-linux-gnu/
    cp emacs/lib-src/rcs2log     $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/x86_64-linux-gnu/
    cp emacs/lib-src/hexl        $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/x86_64-linux-gnu/
    cp emacs/lib-src/movemail    $PKG_WORK_DIR/usr/local/libexec/emacs/"$EMACS_VERSION"/x86_64-linux-gnu/
fi
md5sum                       $PKG_WORK_DIR/usr/local/bin/emacs > $PKG_WORK_DIR/DEBIAN/md5sums

# Set params
ISIZE=$(du -ks $PKG_WORK_DIR/usr | awk '{print $1}')
VERSION="$EMACS_VERSION"-$(date "+%Y-%m-%d-%H-%M")
cat << EOS > $PKG_WORK_DIR/DEBIAN/control
Package: emacs
Version: $VERSION
Architecture: $DEB_ARCH
Maintainer: self build
Installed-Size: $ISIZE
Section: devel
Priority: optional
Homepage: http://www.example.com/
Description: emacs $EMACS_VERSION for my own build
EOS

# Build deb package
fakeroot dpkg-deb --build $PKG_WORK_DIR .
