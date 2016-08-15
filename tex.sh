#!/bin/bash
filename=`basename -s .md $1`
kramdown -o latex --template document $filename.md > $filename.tex
sed -i 's/scrartcl/scrbook/g' $filename.tex
sed -i 's/section/chapter/g' $filename.tex

