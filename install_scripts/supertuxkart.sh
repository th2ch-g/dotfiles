#!/bin/bash
set -e

URL=https://github.com/supertuxkart/stk-code/releases/download/1.4/SuperTuxKart-1.4-linux-x86_64.tar.xz

wget
tar Jxfv SuperTuxKart-1.4-linux-x86_64.tar.xz
rm -f SuperTuxKart-1.4-linux-x86_64.tar.xz

echo done
