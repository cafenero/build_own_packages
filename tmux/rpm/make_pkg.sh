#!/bin/bash -e

if [ $# -ne 2 ]; then
  echo "specify tmux verion and arch!"
  echo "ex: ./make_deb_package.sh 3.3 amd64"
  echo "ex: ./make_deb_package.sh 3.3 arm64"
  exit 1
fi
TMUX_VERSION=$1
RPM_ARCH=$2

# Cleanup
WORK_DIR=work-dir
if [[ -d $WORK_DIR ]]; then
    rm -rf $WORK_DIR
fi
mkdir work-dir
cd $WORK_DIR

# Build tmux
if [ "$EUID" -eq 0 ]; then
         yum install -y git make rpm-build automake gcc byacc libevent-devel libevent ncurses-devel ncurses
else
    sudo yum install -y git make rpm-build automake gcc byacc libevent-devel libevent ncurses-devel ncurses
fi
git clone https://github.com/tmux/tmux.git
cd tmux
git checkout "${TMUX_VERSION}"
sh autogen.sh
./configure
make
cd ..

# Prepare files
BUILDDIR=$(pwd)/buildroot
mkdir -p "$BUILDDIR"/SOURCES
cp tmux/tmux   "$BUILDDIR"/SOURCES/
cp tmux/tmux.1 "$BUILDDIR"/SOURCES/

# Set params
VERSION=$TMUX_VERSION.$(date "+%Y.%m.%d.%H.%M")
SPEC=tmux.spec
cat << EOS > ./$SPEC
Name:    tmux
Version: ${TMUX_VERSION}
Release: ${VERSION}%{?dist}
Summary: tmux ${TMUX_VERSION} for my own build

License: ISC license
Source0: tmux
Source1: tmux.1

%description
tmux ${TMUX_VERSION} for my own build

%install
mkdir -p %{buildroot}/usr/local/bin
install -p -m 755 %{SOURCE0} %{buildroot}/usr/local/bin


mkdir -p %{buildroot}/usr/local/share/man/man1/
install -p -m 755 %{SOURCE1} %{buildroot}/usr/local/share/man/man1/

%files
/usr/local/bin/tmux
/usr/local/share/man/man1/tmux.1
EOS

# Build deb package
rpmbuild --define "_topdir ${BUILDDIR}" -bb ./$SPEC


if [[ $RPM_ARCH == "arm64" ]]; then
    cp "$BUILDDIR"/RPMS/aarch64/*.rpm .
else
    cp "$BUILDDIR"/RPMS/x86_64/*.rpm .
fi

# cp "$BUILDDIR"/RPMS/x86_64/*.rpm .
