#!/bin/bash

while true; do inotifywait -r -e modify --exclude=".html" . && pandoc --syntax-definition=bash.xml --highlight-style zenburn-custom.theme --css Font-Awesome/css/all.css -t revealjs -s -o slides.html slides.md -V revealjs-url=./reveal.js; done