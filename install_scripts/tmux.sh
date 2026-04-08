#!/bin/bash
set -eux

source "${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/lib/utils.sh"

TMUX_VERSION="3.5a"
LIBEVENT_VERSION="2.1.11-stable"
NCURSES_VERSION="6.2"
TMUX_PREFIX="${PWD}/tmux-${TMUX_VERSION}/build"
NCURSES_PREFIX="${PWD}/ncurses-${NCURSES_VERSION}/build"
LIBEVENT_PREFIX="${PWD}/libevent-${LIBEVENT_VERSION}/build"
thread=$(detect_nproc)

[ -d "tmux-${TMUX_VERSION}" ] && { print_info "tmux-${TMUX_VERSION} already present, skipping"; exit 0; }

# release link
TMUX_URL=https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
LIBEVENT_URL=https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz
NCURSES_URL=http://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz

curl -L $TMUX_URL -o tmux.tar.gz &
curl -L $LIBEVENT_URL -o libevent.tar.gz &
curl -L $NCURSES_URL -o ncurses.tar.gz &
wait

tar -xvzf tmux.tar.gz &
tar -xvzf libevent.tar.gz &
tar -xvzf ncurses.tar.gz &
wait

rm -f tmux.tar.gz libevent.tar.gz ncurses.tar.gz

cd ncurses-${NCURSES_VERSION}
./configure --prefix=${NCURSES_PREFIX} --enable-pc-files \
    --with-pkg-config-libdir=${NCURSES_PREFIX}/lib/pkgconfig --with-termlib \
    && make -j $thread && make install
cd ..
print_info "ncurses install done"

cd libevent-${LIBEVENT_VERSION}
./configure --prefix=${LIBEVENT_PREFIX} \
    && make -j $thread && make install
cd ..
print_info "libevent install done"

cd tmux-${TMUX_VERSION}
./configure --prefix=${TMUX_PREFIX} \
    LDFLAGS="-L${NCURSES_PREFIX}/lib -L${LIBEVENT_PREFIX}/lib" \
    CFLAGS="-I${NCURSES_PREFIX}/include -I${LIBEVENT_PREFIX}/include" \
    && make -j $thread \
    && make install
cd ..

ensure_bin ${TMUX_PREFIX}/bin/tmux

print_info "tmux install done"
