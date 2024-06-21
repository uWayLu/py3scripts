#!/usr/bin/bash
# example: 
#   move $WORKDIR/xxxx-國泰世華-xxxxx.pdf to $TODIR/國泰世華12345678/

WORKDIR=$1
TODIR=$2

cd $WORKDIR

keywords=$(ls -1 *.pdf | awk -F- '{print $2}' | sort | uniq)

for kw in $keywords; do
    kwdir=$(echo $TODIR/$kw*)
    kwpdfs=$(ls *.pdf | grep $kw)
    if [! -d $kwdir]; then
        echo "$kwdir not exists"
        continue
    fi
    echo "mv $kwpdfs to $kwdir"
    ls | grep $kw | xargs mv -t "$(echo $kwdir)"
done
