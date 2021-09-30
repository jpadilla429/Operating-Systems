#!/usr/bin/bash

BOOKMARKS=~/Documents/OS/bookmarks.txt

# check if file exists/read/write perm
if [[ ! -f $BOOKMARKS ]]; then
    echo "File does not exist"
    exit 1
elif [[ ! -r $BOOKMARKS ]]; then
    echo "File does not have read permission"
    exit 1
elif [[ ! -w $BOOKMARKS ]]; then
    echo "File does not have write permission"
    exit 1
fi

function list () #Lists all bookmarks in bookmark.txt file
{
    awk -F ":" '{printf "%-13s %-50s %-5s\n", $1, $2, $3}' $BOOKMARKS 
}

function show () #Shows bookmark contents 
{
    #if bookmarkk does not exist, then exit with error
    cat $BOOKMARKS | grep -E '^'$1':' >> /dev/null
    if [[ $? != 0 ]]; then
        echo "Bookmark not found"
        exit 1
    else #show bookmark DIR PATH and count of visits
    cat $BOOKMARKS | grep -E '^'$1':' | awk -F ":" '{print $2 "  " $3}'
    fi
}

function create () #Creates a bookmark if it doesnt exist
{
    #if argument is NOT a valid directory
    if [[ ! -d $2 ]]; then 
        echo "Please enter a valid directory"
        exit 1
    fi

    #if directory bookmark exist, exit with error
    cat $BOOKMARKS | grep -E '.*:'$2':.*' >> /dev/null
    if [[ $? = 0 ]]; then
        echo "Bookmark already exist for this directory"
        exit 1
    fi

    #if bookmark name is already in use, exit with error
    cat $BOOKMARKS | grep -E '^'$1':' >> /dev/null
    if [[ $? = 0 ]]; then
        echo "Bookmark name already in use"
        exit 1
    fi
    #create bookmark with a visit count of 0
    echo "$1:$2:0" >> $BOOKMARKS
}

function remove ()
{   #if bookmark is not on list then exit
    cat $BOOKMARKS | grep -E '^'$1':' >> /dev/null
    if [[ $? != 0 ]]; then
        echo "Bookark does not exist"
        exit 1
    else #else remove bookmark
        sed -i '/^'$1':/d' $BOOKMARKS
    fi
}

function visit () #visits directory of bookmark entered
{
    #if bookmark is NOT on list then exit
    cat $BOOKMARKS | grep -E '^'$1':' >> /dev/null
    if [[ $? != 0 ]]; then
        echo "Bookark not found"
        exit 1
    fi

    #capture the directory to visit
    dir="$(cat $BOOKMARKS | grep -E '^'$1':' | awk -F ":" '{print $2}')"

    #capture the current count of visits AND increase by ONE
    visit="$(cat $BOOKMARKS | grep -E '^'$1':' | awk -F ":" '{print $3+1}')"

    #find previous bookmark entry and replace with new entry with +1 visit cnt
    sed -E -i 's|^'$1':'$dir':[0-9]*|'$1':'$dir':'$visit'|' $BOOKMARKS

    cd $dir # visit directory
    pwd #show current directory
    
}

case $1 in # Functions Case Statements
    list) 
        if [[ $# != 1 ]]; then
            echo "Invalid arguments"
            exit 1
        else
            list
        fi ;;
    show) 
        if [[ $# != 2 ]]; then
            echo "Invalid arguments"
            exit 1
        else
            show $2
        fi ;;
    create)
        if [[ $# != 3 ]]; then
            echo "Invalid arguments"
            exit 1
        else
            create $2 $3
        fi ;;
    remove)
        if [[ $# != 2 ]]; then
            echo "Invalid arguments"
            exit 1
        else
            remove $2
        fi ;;
    visit)
        if [[ $# != 2 ]]; then
            echo "Invalid arguments"
            exit 1
        else
            visit $2
        fi;;
    *)
        echo "Invalid command"
        ;;
esac