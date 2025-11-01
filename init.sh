#!/bin/bash


function import_script() {
    if [ -f $1 ];then
        source $1
    fi
}

function commit_quick(){
    git add -A
    git commit -m "commit auto at $(date +"%Y%m%d %H%M%S")"
    git push github main
}