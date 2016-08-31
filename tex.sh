#!/bin/bash
if ! $(which pdflatex &>/dev/null); then
    sudo apt-get install texlive texlive-latex-recommended texlive-latex-extra
fi

filename=`basename -s .md $1`
dirname=`dirname $1`

cd "$dirname"

kramdown -o latex --template document "$filename".md > "$filename".tex
# especificamos formato Koma-Script Book y formato de página A5
sed -i 's/{scrartcl}/[a5paper]{scrbook}/g' "$filename".tex
# Convertimos secciones en capítulos para que funcione la importación desde markdown
sed -i 's/section/chapter/g' "$filename".tex
pdflatex "$filename".tex

xdg-open "$filename".pdf
read

git add *.md *.pdf; git commit -m "BB update: `date`"; git push;
