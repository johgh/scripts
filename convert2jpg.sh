#!/bin/bash

    # convert "$dir_name/$base_name.png" "$dir_name/$base_name.jpg"
    # trash "$dir_name/$base_name.png"

# DIR=/home/jorge/LaravelProjects/mycardsDB/storage/app/public/images/works/oku_test

find "$DIR" -name "*.jpg" -size +$((512*1024))c -size -$((1*1024*1024))c  | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 60% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done

find "$DIR" -name "*.jpg" -size +$((1*1024*1024))c -size -$((2*1024*1024))c  | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 55% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done


find "$DIR" -name "*.jpg" -size +$((2*1024*1024))c -size -$((3*1024*1024))c  | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 50% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done

find "$DIR" -name "*.jpg" -size +$((3*1024*1024))c -size -$((4*1024*1024))c | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 45% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done

find "$DIR" -name "*.jpg" -size +$((4*1024*1024))c -size -$((5*1024*1024))c | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 40% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done

find "$DIR" -name "*.jpg" -size +$((5*1024*1024))c | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    convert -strip -interlace Plane -quality 35% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
    echo "convert $dir_name/$base_name.jpg"
done
