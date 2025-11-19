#!/bin/bash
set -e

URL="https://github.com/google-gemini/gemini-cli/releases/download/v0.18.0-nightly.20251118.7cc5234b9/gemini.js"
wget $URL
chmod a+x gemini.js
mv gemini.js gemini

echo done
