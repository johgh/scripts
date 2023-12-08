#!/bin/bash
i=0;
while read p; do
    i=$((i+1));
    mkdir "$i. $p"
done <./dirs.txt

