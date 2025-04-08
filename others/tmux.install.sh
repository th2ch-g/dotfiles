#!/bin/bash

# Tested at CentOS

set -e

# release link
thread=15
install_path=$PWD
tmux_link=https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
libevent_link=https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz
ncurses_link=http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz

curl -L $tmux_link -o tmux.tar.gz &
curl -L $libevent_link -o libevent.tar.gz &
curl -L $ncurses_link -o ncurses.tar.gz &
wait

tar -xvzf tmux.tar.gz &
tar -xvzf libevent.tar.gz &
tar -xvzf ncurses.tar.gz &
wait

rm -f *.tar.gz

cd ncurses*
./configure --prefix=${install_path} --enable-pc-files \
    --with-pkg-config-libdir=${install_path}/lib/pkgconfig --with-termlib \
    && make -j $thread && make install
cd ..
echo "[INFO] ncurses install done" >&1

cd libevent*
./configure --prefix=${install_path} \
    && make -j $thread && make install
cd ..
echo "[INFO] libevent install done" >&1

cd tmux*
PKG_CONFIG_PATH=${install_path}/lib/pkgconfig
./configure --prefix=$PWD \
    LDFLAGS="-L${install_path}/lib" CFLAGS="-I${install_path}/include" \
    && make -j $thread
cd ..


echo "[INFO] tmux install done" >&1
mv ./tmux*/tmux ./hoge
echo "[INFO] delete unnecessary file" >&1
rm -rf libevent* ncurses* include share bin tmux*
mv hoge tmux
echo "[INFO] tmux version is" >&1
export LD_LIBRARY_PATH=${install_path}/lib:$LD_LIBRARY_PATH # necessary path
./tmux -V

