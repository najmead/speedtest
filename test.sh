#!/bin/bash

email="youremail@email.com"
domain="yourdomain.com"

## Initialise

#command -v dig >/dev/null 2>&1 || { echo >&2 "[ERROR]: I require dig but it's not installed.  Aborting."; exit 1; }
command -v sqlite3 >/dev/null 2>&1 || { echo >&2 "[ERROR]: I require sqlite3 but it's not installed.  Aborting."; exit 1; }

if [ ! -e data.db ];
then
	echo "[INFO]: Initialising database"
	create="create table test (ID integer primary key, TestTime text, Home text, Server text, Download real, Upload real);"
	sqlite3 data.db "${create}"
fi


## Run Test

if [ -e output.txt ];
then
	echo "[INFO]: Cleaning up previous outputs"
	rm output.txt
fi

if [ ! -e speedtest ];
then	
	echo "[WARNING]: Python script is missing.  Downloading."
	wget -O speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
	chmod +x speedtest
fi

echo "[INFO]: Running speed test (this could take a few minutes)"
datetime=$(date +"%Y-%m-%d %T")
#myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
./speedtest > output.txt
download=`grep Download output.txt |cut -d ':' -f 2|cut -d ' ' -f 2`
upload=`grep Upload output.txt|cut -d ':' -f 2|cut -d ' ' -f 2`
source=`grep 'Testing from' output.txt |cut -d '(' -f2|cut -d ')' -f1`
destination=`grep 'Hosted by' output.txt`

echo "[INFO]: Inserting data into logging database"
insert="insert into test (TestTime, Home, Server, Download, Upload) values ('${datetime}', '${source}', '${destination/Hosted by /}', '${download}', '${upload}')"
sqlite3 data.db "${insert}"

if [ -e output.txt ];
then
	echo "[INFO]: Cleaning up leftover files"
	rm output.txt
fi

## Perform comparison

query="select count(distinct Home) from test where TestTime in (select TestTime from test order by TestTime desc limit 0,2);"
difftest=$(sqlite3 data.db "${query}")

if [ $difftest -ne 1 ];
then
        msg="[WARNING]: IP Address has changed since last run.  New IP is ${source}"
        echo $msg
        mail -s "[${domain}]: IP Address Update" $email <<< $msg
fi




