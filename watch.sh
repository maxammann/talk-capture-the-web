#!/bin/bash

build () {
    pandoc --syntax-definition=bash.xml --highlight-style zenburn-custom.theme --css style.css --css Font-Awesome/css/all.css -t revealjs -s -o deploy/index.html slides.md -V revealjs-url=./reveal.js --self-contained
}

build

while true; do inotifywait -r -e modify --exclude=".html" . && build ; done
