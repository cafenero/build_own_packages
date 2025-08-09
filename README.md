# build_own_packages

## build tmux
deb
```
cd build_own_packages/tmux/deb/
./make_pkg.sh 3.3 amd64
sudo apt install ./tmux_3.3-2023-03-16-19-58_amd64.deb
```

CentOS7 rpm
```
cd build_own_packages/tmux/rpm/
./run_all.sh 3.3 amd64
sudo yum install ./tmux-3.3-2023.03.16.10.59.el7.x86_64.rpm
```


## build emacs
deb
```
cd build_own_packages/emacs/deb/
./make_pkg.sh 28.2 amd64
sudo apt install ./emacs_28.2-2023-03-16-19-58_amd64.deb
```

CentOS7 rpm
```
cd build_own_packages/emacs/centos7/
./run_all.sh 28.2 amd64
sudo yum install ./emacs-28.2-2023.03.16.10.59.el7.x86_64.rpm
```

RockyLinux9 rpm
```
cd build_own_packages/emacs/rocky9/
./run_all.sh 28.2 amd64
sudo yum install emacs-28.2-2025.08.09.08.33.el9.x86_64.rpm
```
