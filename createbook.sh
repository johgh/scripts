#!/bin/bash
usage() { echo "$(basename $0) [-f <a4|a5>] [-m <book>|<article>] [-b] [-i <header|footer|body>] <filename>.md
NOTA: switch -b genera fichero .ps con 2 páginas por A4 en formato folleto" 1>&2; exit 1; }

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
m=default
included_args=()
included=()
included+=('header')
included+=('footer')
included+=('body')

while getopts ":f:i:bm:" o; do
case "${o}" in
    f)
        f=${OPTARG}
        if [[ "$f" != 'a4' && "$f" != 'a5' ]]; then usage; fi
        ;;
    m)
        m=${OPTARG}
        if [[ "$m" != 'book' && "$m" != 'article' ]]; then usage; fi
        ;;
    b)
        b=true
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

# si se especifica la opción "libro" el formato siempre es A5
if [[ "$b" == true ]]; then
    f=a5
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
    sed -i 's/\\section{\([^}]*\)}.*$//g' "$filename".tex
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
if [[ "$m" == 'article' ]]; then
    sed -i 's/\\documentclass.*$/\\documentclass['"$f"'paper]{scrartcl}/g' "$filename".tex
    articlestructure
fi

if [[ "$m" == 'book' ]]; then
    sed -i 's/\\documentclass.*$/\\documentclass['"$f"'paper]{scrbook}/g' "$filename".tex
    bookstructure
fi

##### CONVERSIÓN A FICHERO FINAL #####
if [[ "$b" != true ]]; then
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode "$filename".tex
    pdflatex "$filename".tex
    xdg-open "$filename".pdf
else
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode -output-format dvi "$filename".tex
    pdflatex -draftmode -output-format dvi "$filename".tex
    dvips "$filename".dvi
    psbook -s4 "$filename".ps | psnup -p a4 -s1 -2 > "$filename"_readytoprint.ps
    xdg-open "$filename"_readytoprint.ps
fi
# limpieza
# rm *.toc *.dvi *.aux *.out *.log "$filename".tex "$filename".ps body.tex 2> /dev/null

##### SUBIDA DE FICHEROS FUENTE TRAS PREVISUALIZACIÓN #####
read
. $HOME/conf/.alias_functions
git add *.md header.tex intro.tex footer.tex
git commit -m "'BB update: `date`'"
git p
