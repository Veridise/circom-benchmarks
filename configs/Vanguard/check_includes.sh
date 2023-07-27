#!/bin/bash

# Checks all the tests and makes sure the relative paths in the include
# exists relative to the circom file that is invoking it.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

find $SCRIPT_DIR/../../tests/vulnerabilities -name test.json |\
     xargs jq -r '.tests[] | [(input_filename | split("/") | .[:-1] | join("/")), .main] | join("/")' |\
     while read file; do 
        echo "Processing $file"
        if [ ! -f $file ]; then echo "File NOT FOUND!"; continue; fi

        pushd $(dirname $file)
        egrep '^\s*include' $file | sed -r 's/include "(.*)";/\1/' | while read include; do
            echo $include
            if [ ! -f $include ]; then
                echo "In file $file the include $include is not correct!"
            fi
        done 
        popd
     done | grep "^In file"