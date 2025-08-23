#!/bin/bash
# ------------------------------------------------------------------------------
# This is a helper script used by the Makefile.
# 
# It will copy the SRC file to the DST directory, IFF the SRC file exists. If SRC
# does NOT exist, it will instead create an empty file in the DST directory.
# 
# Usage: user_file.sh SRC DST
#     * SRC - Path to a file
#     * DST - Path to a directory
# ------------------------------------------------------------------------------
SRC=$1
DST=$2
FILE=""

if [ "X$SRC" == "X" -o "X$DST" == "X" ]; then
    echo "Usage: $0 SRC DST"
    exit 1
fi

if [ -d $SRC ]; then
    echo "Error: SRC must be a file, not a directory."
fi

if [ -d $DST ]; then
    FILE=`basename $SRC`
    DST="$DST/$FILE"
fi

# ------------------------------------------------------------------------------

if [ -f $SRC ]; then
    cp $SRC $DST
else
    touch $DST
fi
