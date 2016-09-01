#!/bin/bash
# get git pass
. $HOME/conf/.alias_functions

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
# se cambia regla horizontal por asteriscos
sed -i 's/\\rule{3in}{0.4pt}/* * */g' "$filename".tex


pdflatex "$filename".tex

xdg-open "$filename".pdf
read

/usr/bin/git add *.md *.pdf
/usr/bin/git commit -m "'BB update: `date`'"
$HOME/bin/ansbot '*?assword*' $GIT_PASS ''/usr/bin/git p''
