#!/bin/bash
filename=`basename -s .md $1`
kramdown -o latex --template document $filename.md > $filename.tex
# especificamos formato Koma-Script Book y formato de página A5
sed -i 's/{scrartcl}/[a5paper]{scrbook}/g' $filename.tex
# Convertimos secciones en capítulos para que funcione la importación desde markdown
sed -i 's/section/chapter/g' $filename.tex
