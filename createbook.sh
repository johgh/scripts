#!/bin/bash
. $HOME/conf/.alias_functions

if ! $(which pdflatex &>/dev/null); then
    sudo apt-get install texlive texlive-latex-recommended texlive-latex-extra psutils
fi

if ! $(which psbook &>/dev/null); then
    sudo apt-get install psutils
fi

filename=`basename -s .md $1`
dirname=`dirname $1`

cd "$dirname"

##### CONVERSIÓN DE KRAMDOWN A LATEX #####
kramdown -o latex --template document "$filename".md > "$filename".tex


##### POSTPROCESO DEL FICHERO TEX #####
# se cambia regla horizontal por asteriscos
sed -i 's/\\rule{3in}{0.4pt}/* * */g' "$filename".tex
# puntos suspensivos sin espacios
sed -i 's/\\ldots{}/.../g' "$filename".tex
# guiones más largos, es temporal, al terminar e escribir .md, se hará un reemplazar de guión por 3 guiones excepto en guiones estándar
sed -i 's/-/---/g' "$filename".tex
# espacio vertical
sed -i 's/> > >/\\bigskip/g' "$filename".tex
# cambios según formato final que se quiere obtener
if [[ ! -z $2 ]]; then
    if [[ $2 == '--a4' ]]; then
        # formato A4 limpio, sin cabecera ni pie
        sed -i 's/{scrartcl}/[a4paper]{scrartcl}/g' "$filename".tex
    else
        if [[ $2 == '--print' ]]; then
            # formato listo para imprimir
            sed -i 's/section/chapter/g' "$filename".tex
            sed -n '/\\begin{document}/,/\\end{document}/P' "$filename".tex | head -n-1 | tail -n+2 > body.tex
            cat header.tex body.tex footer.tex > "$filename".tex
        fi
    fi
else
    # formato A5 limpio, sin cabecera ni pie
    sed -i 's/section/chapter/g' "$filename".tex
    sed -i 's/{scrartcl}/[a5paper]{scrbook}/g' "$filename".tex
fi


##### CONVERSIÓN A FICHERO FINAL #####
if [[ -z $2 || $2 == '--a4' ]]; then
    # formato pdf
    pdflatex "$filename".tex
    xdg-open "$filename".pdf
else
    # formato ps para imprimir 2 páginas A5 en cada A4 en formato folleto (psbook -s4)
    pdflatex -output-format dvi "$filename".tex
    dvips "$filename".dvi
    psbook -s4 "$filename".ps | psnup -p a4 -s1 -2 > "$filename"_readytoprint.ps
    xdg-open "$filename"_readytoprint.ps
fi


##### SUBIDA DE FICHEROS FUENTE TRAS PREVISUALIZACIÓN (SUBIDA ENCRIPTADA) #####
read
git add *.md header.tex footer.tex
git commit -m "'BB update: `date`'"
git p
