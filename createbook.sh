#!/bin/bash
usage() { echo "$(basename $0) [-f <a4|a5>] [-m <pagebreaks|cont>] [-j <book|dual>] [-i <header|footer|body>] <filename>.md
- opciones:
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
        -i especifica que partes se incluyen en el documento (se pueden escoger varias especificando varias veces el parámetro)

- plantillas .tex (a incluir en el mismo directorio que el fichero .md):
        - header.tex: páginas iniciales del documento en formato latex
        - footer.tex: páginas finales del documento en formato latex" 1>&2; exit 1; }

dependencies() {
    if ! $(which pdflatex &>/dev/null); then sudo apt-get install texlive texlive-latex-recommended texlive-latex-extra psutils; fi
    if ! $(which psbook &>/dev/null); then sudo apt-get install psutils; fi
    if ! $(which psbook &>/dev/null); then sudo apt-get install psutils; fi
    if ! $(which okular &>/dev/null); then sudo apt-get install okular; fi
    if ! $(which evince &>/dev/null); then sudo apt-get install evince; fi
}

##### PARSEO DE PARÁMETROS RECIBIDOS #####
# definición de parámetros por defecto
f=a5
j=default
m=default
included_args=()
included=()
included+=('header')
included+=('footer')
included+=('body')

# parámetros recibidos
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

# si se han especificado por parametro partes a incluir sobreescrimos las que vienen por defecto
if [ ! -z $included_args ]; then
    included=(${included_args[*]})
fi

# comprobamos que el fichero pasado por parámetro exista
shift $(( OPTIND - 1 ))
if [[ ! -f $@ || -z $@ || ! $(echo $@ | grep '.md') ]]; then
    usage
fi


##### PREPARACIÓN ENTORNO #####
# comprobación de dependencias
dependencies
filename=`basename -s .md $@`
dirname=`dirname $@`
# cambio al directorio de trabajo
cd "$dirname"
# limpieza de ficheros generados en ejecuciones anteriores
rm "$filename".pdf "$filename".ps 2> /dev/null


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

# añadimos cabecera (latex)
cat <<EOF > "$filename".tex
\documentclass
\usepackage[utf8x]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{listings}
\setcounter{footnote}{0}
\makeatletter
\@ifundefined{date}{}{\date{}}
\makeatother
\renewcommand{\contentsname}{{ÍNDICE}}
\renewcommand{\partname}{Parte}
\begin{document}
EOF

if [[ " ${included[@]} " =~ " header " ]]; then cat header.tex >> "$filename".tex 2> /dev/null; fi
if [[ " ${included[@]} " =~ " body " ]]; then cat body.tex >> "$filename".tex 2> /dev/null; fi
if [[ " ${included[@]} " =~ " footer " ]]; then cat footer.tex >> "$filename".tex 2> /dev/null; fi

# añadimos marca de fin de documento (latex)
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
notvalidparts() {
    echo -e "Included parts not found or invalid syntax: $included\nPlease include your header.tex and/or footer.tex file in the same directory as your .md file"
    exit 1
}

if [[ "$j" == 'default' ]]; then
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode "$filename".tex >/dev/null 2>&1
    pdflatex "$filename".tex >/dev/null 2>&1
    if [[ ! -f "$filename".pdf ]]; then notvalidparts; fi
    nohup evince "$filename".pdf >/dev/null 2>&1 &
else
    # se compila 2 veces para obtener TOC actualizada
    pdflatex -draftmode -output-format dvi "$filename".tex >/dev/null 2>&1
    pdflatex -draftmode -output-format dvi "$filename".tex >/dev/null 2>&1
    if [[ ! -f "$filename".dvi ]]; then notvalidparts; fi
    dvips -q "$filename".dvi
    mv "$filename".ps "$filename"_temp.ps
    if [[ "$f" == 'a5' ]]; then paramspsn=' -q -p a4 -s1 '; else paramspsn=' -q -p a4 '; fi
    if [[ "$j" == 'dual' ]]; then
        cat "$filename"_temp.ps | psnup $paramspsn -2 > "$filename".ps
    else
        psbook -q -s4 "$filename"_temp.ps | psnup $paramspsn -2 > "$filename".ps
    fi
    nohup okular "$filename".ps >/dev/null 2>&1 &
fi


##### LIMPIEZA DE FICHEROS TEMPORALES #####
rm *.toc *.dvi *.aux *.out *.log "$filename"_temp.ps "$filename".tex body.tex 2> /dev/null

