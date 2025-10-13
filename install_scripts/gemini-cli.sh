#!/bin/bash
set -e

URL="https://github.com/google-gemini/gemini-cli/releases/download/v0.9.0-preview.2/gemini.js"
wget $URL
chmod a+x gemini.js
mv gemini.js gemini

echo done
