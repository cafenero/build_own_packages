#!/bin/bash -e

if [ $# -ne 2 ]; then
  echo "specify emacs verion and arch!"
  echo "ex: ./make_deb_package.sh 28.2 amd64"
  echo "ex: ./make_deb_package.sh 28.2 arm64"
  exit 1
fi
EMACS_VERSION=$1
RPM_ARCH=$2

# Cleanup
WORK_DIR=work-dir
if [[ -d $WORK_DIR ]]; then
    rm -rf $WORK_DIR
fi
mkdir work-dir
cd $WORK_DIR

# Build emacs
if [ "$EUID" -eq 0 ]; then
         yum install -y git rpm-build gcc automake ncurses-devel texinfo gnutls-devel wget
else
    sudo yum install -y git rpm-build gcc automake ncurses-devel texinfo gnutls-devel wget
fi

wget http://ftp.jaist.ac.jp/pub/GNU/emacs/emacs-"$EMACS_VERSION".tar.gz
tar xf emacs-"$EMACS_VERSION".tar.gz
mv emacs-"$EMACS_VERSION" emacs
cd emacs
./autogen.sh
./configure --without-x
make -j
cd ..

# Prepare files
BUILDDIR=$(pwd)/buildroot
rm -rf "$BUILDDIR"
mkdir -p                     "$BUILDDIR"/SOURCES/
cp emacs/lib-src/ctags       "$BUILDDIR"/SOURCES/
cp emacs/lib-src/ebrowse     "$BUILDDIR"/SOURCES/
cp emacs/lib-src/emacsclient "$BUILDDIR"/SOURCES/
cp emacs/lib-src/etags       "$BUILDDIR"/SOURCES/
cp emacs/src/emacs           "$BUILDDIR"/SOURCES/
cp -r emacs/src              "$BUILDDIR"/SOURCES/
cp -r emacs/lisp             "$BUILDDIR"/SOURCES/
cp -r emacs/doc/man/*        "$BUILDDIR"/SOURCES/
cp -r emacs/etc/             "$BUILDDIR"/SOURCES/
cp -r emacs/info             "$BUILDDIR"/SOURCES/

# Set params
RELEASE=$(date "+%Y.%m.%d.%H.%M")
SPEC=emacs.spec
cat << EOS > ./$SPEC
Name:    emacs
Version: ${EMACS_VERSION}
Release: ${RELEASE}%{?dist}
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
mkdir -p %{buildroot}/usr/local/share/man/man1
mkdir -p %{buildroot}/usr/local/share/emacs/info
mkdir -p %{buildroot}/usr/local/share/emacs/${EMACS_VERSION}/etc/charsets
install -p -m 755 %{SOURCE0} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE1} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE2} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE3} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE4} %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE5} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE6} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE7} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE8} %{buildroot}/usr/local/share/man/man1
install -p -m 755 %{SOURCE9} %{buildroot}/usr/local/share/man/man1
EOS

if [[ $RPM_ARCH == "arm64" ]]; then
  echo mkdir -p %{buildroot}/usr/local/libexec/emacs/${EMACS_VERSION}/aarch64-unknown-linux-gnu/ >> ./$SPEC
  echo install -p -m 755 "$BUILDDIR/SOURCES/src/emacs.pdmp %{buildroot}/usr/local/libexec/emacs/${EMACS_VERSION}/aarch64-unknown-linux-gnu/emacs.pdmp" >> ./$SPEC
else
  echo mkdir -p %{buildroot}/usr/local/libexec/emacs/${EMACS_VERSION}/x86_64-pc-linux-gnu/ >> ./$SPEC
  echo install -p -m 755 "$BUILDDIR/SOURCES/src/emacs.pdmp %{buildroot}/usr/local/libexec/emacs/${EMACS_VERSION}/x86_64-pc-linux-gnu/emacs.pdmp" >> ./$SPEC
fi

# 仮想インストール先にlisp用のディレクトリを先に作っておく。
for f in $(find "$BUILDDIR"/SOURCES/lisp -type d | sed -e s/.*SOURCES\\/// | xargs); do
    echo mkdir -p "%{buildroot}/usr/local/share/emacs/${EMACS_VERSION}/$f" >> ./$SPEC
done

# 仮想インストール先にlispファイルをinstallする。
for f in $(find "$BUILDDIR"/SOURCES/lisp -type f | sed -e s/.*SOURCES\\/// | xargs); do
    echo install -p -m 755 "$BUILDDIR/SOURCES/$f %{buildroot}/usr/local/share/emacs/${EMACS_VERSION}/$f"  >> ./$SPEC
done

# charsets el
for f in $(find "$BUILDDIR"/SOURCES/etc/charsets/ -type f | sed -e s/.*SOURCES\\/// | xargs); do
    echo install -p -m 755 "$BUILDDIR/SOURCES/$f %{buildroot}/usr/local/share/emacs/${EMACS_VERSION}/$f"  >> ./$SPEC
done

# info
for f in $(find "$BUILDDIR"/SOURCES/info/ -type f | sed -e s/.*SOURCES\\/// | xargs); do
    echo install -p -m 755 "$BUILDDIR/SOURCES/$f %{buildroot}/usr/local/share/emacs/$f"  >> ./$SPEC
done

cat << EOS >> ./$SPEC
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
/usr/local/libexec/*
/usr/local/libexec/emacs/*
/usr/local/share/emacs/*
EOS

# Build deb package
rpmbuild --define "_topdir ${BUILDDIR}" -bb ./$SPEC

if [[ $RPM_ARCH == "arm64" ]]; then
    cp "$BUILDDIR"/RPMS/aarch64/*.rpm ./emacs.rpm
else
    cp "$BUILDDIR"/RPMS/x86_64/*.rpm .
fi
