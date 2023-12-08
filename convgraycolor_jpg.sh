#!/bin/bash

    # convert "$dir_name/$base_name.png" "$dir_name/$base_name.jpg"
    # trash "$dir_name/$base_name.png"

# DIR=/home/jorge/LaravelProjects/mycardsDB/storage/app/public/images/works/oku_test

find "$DIR" -name "*.jpg" -size +$((700*1024))c -size -$((1*1024*1024))c  | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    file "$dir_name/$base_name.jpg" | grep 'components 3'
    if [ $? -eq 0 ]; then
        convert -strip -interlace Plane -quality 60% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
        echo "convert $dir_name/$base_name.jpg 60%"
    else
        convert -strip -interlace Plane -quality 30% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
        echo "convert $dir_name/$base_name.jpg 30%"
    fi
done

find "$DIR" -name "*.jpg" -size +$((1*1024*1024))c | while read f
do
    base_name="`basename "$f" .jpg`"
    dir_name="`dirname "$f"`"
    file "$dir_name/$base_name.jpg" | grep 'components 3'
    if [ $? -eq 0 ]; then
        convert -strip -interlace Plane -quality 40% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
        echo "convert $dir_name/$base_name.jpg 40%"
    else
        convert -strip -interlace Plane -quality 20% "$dir_name/$base_name.jpg" "$dir_name/$base_name.jpg"
        echo "convert $dir_name/$base_name.jpg 20%"
    fi
done


