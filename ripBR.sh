#!/bin/bash
firsttrack=1
lasttrack=18

# 1) makemkv con preset flac

# 2) split de los capítulos en ficheros
# nota: al hacer split los flac quedan semicorruptos (los tiempos no quedan bien)
# vlc y Fiio los leen, si cuela cuela......
mkvmerge -o output.mkv --split chapters:all $1

# 3) contenedor mkv a flac final
for var in `seq $firsttrack $lasttrack`
do
    i=$(printf %03d $var)
    mkvextract tracks output-$i.mkv 1:out-$i.flac
done

# 4) poner tags al flac con musicbrainz picard
