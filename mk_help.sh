#!/bin/bash

rm help.md
touch help.md

#dirtoupdate=$( ls -d */)
dirtoupdate="quantumdots measure"

for i in $dirtoupdate;
do
    echo -e "\n\n" >> help.md
    echo "## $(basename $i) ##" >> help.md
    grep -hE "^#" ${i}/*.tcl | sed 's/#//g'| sed 's/@param/ */' | sed 's/@return/\n\nRETURN\n /' | sed 's/ \\file/###/' >> help.md
    echo " -- " >> help.md
done
	
