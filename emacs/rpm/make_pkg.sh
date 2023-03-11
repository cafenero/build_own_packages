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
sudo yum install -y gcc automake ncurses-devel texinfo gnutls-devel
git clone https://github.com/emacs-mirror/emacs.git
cd emacs
git checkout emacs-"$EMACS_VERSION"
./autogen.sh
./configure --without-x
make
cd ..

# Prepare files
BUILDDIR=$(pwd)/buildroot
mkdir -p $BUILDDIR/SOURCES
cp emacs/lib-src/ctags $BUILDDIR/SOURCES/
cp emacs/lib-src/ebrowse $BUILDDIR/SOURCES/
cp emacs/lib-src/emacsclient $BUILDDIR/SOURCES/
cp emacs/lib-src/etags $BUILDDIR/SOURCES/
cp emacs/src//emacs $BUILDDIR/SOURCES/
cp -r emacs/doc/man/* $BUILDDIR/SOURCES/

# Set params
VERSION=$EMACS_VERSION.$(date "+%Y.%m.%d.%H.%M")
SPEC=emacs.spec
echo "hoge"
cat << EOS > ./$SPEC
Name:    emacs
Version: ${EMACS_VERSION}
Release: ${VERSION}%{?dist}
Summary: emacs ${EMACS_VERSION} for my own build
License: GNU

Source0: ctags
Source1: ebrowse
Source2: emacsclient
Source3: etags
Source4: emacs
Source5: ctags.1
Source6: ebrowse.1
Source7: emacs.1
Source8: emacsclient.1
Source9: etags.1

%description
emacs ${EMACS_VERSION} for my own build

%install
mkdir -p %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE0} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE1} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE2} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE3} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE4} %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE5} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE6} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE7} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE8} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE9} %{buildroot}/usr/local/share/man/man1

%files
/usr/local/bin/ctags
/usr/local/bin/ebrowse
/usr/local/bin/emacsclient
/usr/local/bin/etags
/usr/local/bin/emacs
/usr/local/share/man/man1/ctags.1
/usr/local/share/man/man1/ebrowse.1
/usr/local/share/man/man1/emacs.1
/usr/local/share/man/man1/emacsclient.1
/usr/local/share/man/man1/etags.1

EOS

# Build deb package
rpmbuild --define "_topdir ${BUILDDIR}" -bb ./$SPEC
cp $BUILDDIR/RPMS/x86_64/*.rpm .
