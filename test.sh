#!/bin/bash

## Initialise
if [ ! -e data.db ];
then
	echo "Initialising database"
	create="create table test (ID integer primary key, TestTime text, Server text, Download real, Upload real);"
	sqlite3 data.db "${create}"
fi


## Run Test

if [ -e output.txt ];
then
	echo "Cleaning up previous outputs"
	rm output.txt
fi

if [ ! -e speedtest-cli ];
then	
	echo "Python script is missing.  Downloading."
	wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest_cli.py
	chmod +x speedtest-cli
fi

echo "Running speed test (this could take a few minutes)"
datetime=$(date +"%Y-%m-%d %T")
./speedtest-cli > output.txt
download=`grep Download output.txt |cut -d ':' -f 2|cut -d ' ' -f 2`
upload=`grep Upload output.txt|cut -d ':' -f 2|cut -d ' ' -f 2`
server=`grep 'Testing from' output.txt |cut -d '(' -f2|cut -d ')' -f1`

echo "Inserting data into logging database"
insert="insert into test (TestTime, Server, Download, Upload) values ('${datetime}', '${server}', '${download}', '${upload}')"
sqlite3 data.db "${insert}"

if [ -e output.txt ];
then
	echo "Cleaning up leftover files"
	rm output.txt
fi




