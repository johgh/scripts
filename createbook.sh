#!/bin/bash
usage() { echo "$(basename $0) [-f <a4|a5>] [-m <pagebreaks|cont>] [-j <book|dual>] [-i <header|footer|body>] <filename>.md
opciones:
    FORMATO
        -f a5 (modo por defecto): Formato de página A5 (el modo por defecto, -m, es 'pagebreak')
        -f a4: Formato de página A4 (el modo por defecto, -m, es 'cont')
    MODO
        -m cont[inuous]: todo el texto contínuo, sin saltos de página
        -m pagebreaks: partes y capítulos con saltos de página (estilo libro)
    JUNTAR
        -j dual: junta 2 páginas en cada A4 con ordenación estándar
        -j book: pone 2 páginas en cada A4 en formato folleto
    INCLUIR
        -i especifica que partes se incluyen en el documento (se pueden escoger varias especificando varias veces el parámetro)" 1>&2; exit 1; }

dependencies() {
    if ! $(which pdflatex &>/dev/null); then
        sudo apt-get install texlive texlive-latex-recommended texlive-latex-extra psutils
    fi

    if ! $(which psbook &>/dev/null); then
        sudo apt-get install psutils
    fi
}

# parámetros por defecto
f=a5
j=default
m=default
included_args=()
included=()
included+=('header')
included+=('footer')
included+=('body')

while getopts ":f:i:j:m:" o; do
case "${o}" in
    f)
        f=${OPTARG}
        if [[ "$f" != 'a4' && "$f" != 'a5' ]]; then usage; fi
        ;;
    m)
        m=${OPTARG}
        if [[ "$m" != 'pagebreaks' && "$m" != 'cont' ]]; then usage; fi
        ;;
    j)
        j=${OPTARG}
        if [[ "$j" != 'book' && "$j" != 'dual' ]]; then usage; fi
        ;;
    i)
        i=${OPTARG}
        if [[ "$i" != 'header' && "$i" != 'footer' && "$i" != 'body' ]]; then usage; fi
        included_args+=($i)
        ;;
    *)
        usage
        ;;
esac
done

# si se han especificado por parametro partes a incluir sobreescrimos las de por defecto
if [ ! -z $included_args ]; then
    included=(${included_args[*]})
fi

# comprobamos que el fichero pasado por parámetro exista
shift $(( OPTIND - 1 ))
if [[ ! -f $@ || -z $@ ]]; then
    usage
fi

# comprobación de dependencias
dependencies

filename=`basename -s .md $@`
dirname=`dirname $@`

# echo $filename
# exit

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

##### INCLUIMOS PARTES SELECCIONADAS SEGÚN PARÁMETROS #####
sed -n '/\\begin{document}/,/\\end{document}/P' "$filename".tex | head -n-1 | tail -n+2 > body.tex

cat header.tex > "$filename".tex
if [[ " ${included[@]} " =~ " header " ]]; then cat intro.tex >> "$filename".tex; fi
if [[ " ${included[@]} " =~ " body " ]]; then cat body.tex >> "$filename".tex; fi
if [[ " ${included[@]} " =~ " footer " ]]; then cat footer.tex >> "$filename".tex; fi
echo '\end{document}' >> "$filename".tex

##### FORMATO A4/A5 SEGÚN PARÁMETROS #####
bookstructure() {
    # formato a5, si soporta capítulos a diferencia de scrartcl
    sed -i 's/\\subsection{\([^}]*\)}.*$/\\chapter*{\1}\n\\addcontentsline{toc}{chapter}{\1}/g' "$filename".tex
    # cambiamos section por parte
    sed -i 's/\\section{\([^}]*\)}.*$/\\part*{\1}\n\\addcontentsline{toc}{part}{\1}/g' "$filename".tex
}

articlestructure() {
    # borramos las partes, para ahorrar espacio
    # sed -i 's/\\section{\([^}]*\)}.*$//g' "$filename".tex
    sed -i 's/\\section{\([^}]*\)}.*$/\\section*{\1}\n\\addcontentsline{toc}{section}{\1}/g' "$filename".tex
    # subsecciones, no capítulos
    sed -i 's/\\subsection{\([^}]*\)}.*$/\\subsection*{\1}\n\\addcontentsline{toc}{subsection}{\1}/g' "$filename".tex
}

if [[ "$m" == 'default' ]]; then
    if [[ "$f" == 'a4' ]]; then
        mode=scrartcl
        # formato A4 scrartcl
        sed -i 's/\\documentclass.*$/\\documentclass[a4paper]{scrartcl}/g' "$filename".tex
        articlestructure
    else
        mode=scrbook
        # formato A5 scrbook
        sed -i 's/\\documentclass.*$/\\documentclass[a5paper]{scrbook}/g' "$filename".tex
        bookstructure
    fi
fi

##### FORMATO ARTÍCULO/LIBRO SEGÚN PARÁMETROS #####
if [[ "$m" == 'cont' ]]; then
    sed -i 's/\\documentclass.*$/\\documentclass['"$f"'paper]{scrartcl}/g' "$filename".tex
    articlestructure
fi

if [[ "$m" == 'pagebreaks' ]]; then
    sed -i 's/\\documentclass.*$/\\documentclass['"$f"'paper]{scrbook}/g' "$filename".tex
    bookstructure
fi

##### CONVERSIÓN A FICHERO FINAL #####
if [[ "$j" == 'default' ]]; then
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode "$filename".tex
    pdflatex "$filename".tex
    evince "$filename".pdf
else
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode -output-format dvi "$filename".tex
    pdflatex -draftmode -output-format dvi "$filename".tex
    dvips "$filename".dvi
    mv "$filename".ps "$filename"_temp.ps
    if [[ "$f" == 'a5' ]]; then resize=' -p a4 -s1 '; else resize=' -p a4 '; fi
    if [[ "$j" == 'dual' ]]; then
        cat "$filename"_temp.ps | psnup $resize -2 > "$filename".ps
    else
        psbook -s4 "$filename"_temp.ps | psnup $resize -2 > "$filename".ps
    fi
    okular "$filename".ps
fi
# limpieza
rm *.toc *.dvi *.aux *.out *.log "$filename"_temp.ps "$filename".tex body.tex 2> /dev/null

##### SUBIDA DE FICHEROS FUENTE TRAS PREVISUALIZACIÓN #####
read
. $HOME/conf/.alias_functions
git add *.md header.tex intro.tex footer.tex
git commit -m "'BB update: `date`'"
git p
