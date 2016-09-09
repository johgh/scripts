#!/bin/bash
. $HOME/conf/.alias_functions

if ! $(which pdflatex &>/dev/null); then
    sudo apt-get install texlive texlive-latex-recommended texlive-latex-extra psutils
fi

filename=`basename -s .md $1`
dirname=`dirname $1`

cd "$dirname"

kramdown -o latex --template document "$filename".md > "$filename".tex
sed -n '/\\begin{document}/,/\\end{document}/P' "$filename".tex | head -n-1 | tail -n+2 > body.tex
cat header.tex body.tex footer.tex > "$filename".tex

# especificamos formato Koma-Script Book y formato de página A5
# sed -i 's/{scrartcl}/[a5paper]{scrbook}/g' "$filename".tex

# Convertimos secciones en capítulos para que funcione la importación desde markdown
sed -i 's/section/chapter/g' "$filename".tex
# se cambia regla horizontal por asteriscos
sed -i 's/\\rule{3in}{0.4pt}/* * */g' "$filename".tex
# puntos suspensivos sin espacios
sed -i 's/\\ldots{}/.../g' "$filename".tex
# guiones más largos, es temporal, al terminar e escribir .md, se hará un reemplazar de guión por 3 guiones excepto en guiones estándar
sed -i 's/-/---/g' "$filename".tex
# espacio vertical
sed -i 's/> > >/\\bigskip/g' "$filename".tex

# ejemplo para cambiar varias lineas con \n
# sed -i 's/usepackage{hyperref}/usepackage{hyperref}\n\\usepackage{amsmath}/g' "$filename".tex

pdflatex -output-format dvi "$filename".tex
dvips "$filename".dvi
psbook -s4 "$filename".ps | psnup -s1 -2 > "$filename"_readytoprint.ps

xdg-open "$filename".dvi
read

git add *.md header.tex footer.tex
git commit -m "'BB update: `date`'"
git p
