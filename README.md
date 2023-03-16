# build_own_packages
How to build tmux (deb)
```
cd build_own_packages/tmux/deb/
./make_pkg.sh 3.3 amd64
sudo apt install ./tmux_3.3-2023-03-16-19-58_amd64.deb
```

How to build tmux (rpm)
```
cd build_own_packages/tmux/rpm/
./run_all.sh 3.3 amd64
sudo yum install ./tmux-3.3-2023.03.16.10.59.el7.x86_64.rpm
```

How to build emacs (deb)
```
cd build_own_packages/emacs/deb/
./make_pkg.sh 28.2 amd64
sudo apt install ./emacs_28.2-2023-03-16-19-58_amd64.deb
```

How to build emacs (rpm)
```
cd build_own_packages/emacs/rpm/
./run_all.sh 28.2 amd64
sudo yum install ./emacs-28.2-2023.03.16.10.59.el7.x86_64.rpm
```
