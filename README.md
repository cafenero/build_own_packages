# build_own_packages
How to build tmux
```
cd build_own_packages/tmux/deb/
./make_deb_package.sh 3.3 amd64
sudo apt install ./work-dir/tmux_3.3-2023-03-11-07-00_amd64.deb
```


How to build emacs (rpm)
```
cd build_own_packages/emacs/rpm/
./make_pkg.sh 28.2 amd64
sudo yum install ./emacs-28.2-28.2.2023.03.11.11.45.el7.x86_64.rpm
```
