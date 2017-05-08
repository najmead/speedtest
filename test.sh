#!/bin/bash

influxdb="http://myurlgoeshere:8086"

testdb="network"
table="speedtest"

influxdb_url=${influxdb}"/write?db="${testdb}"&precision=s"

## Initialise

#command -v dig >/dev/null 2>&1 || { echo >&2 "[ERROR]: I require dig but it's not installed.  Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "[ERROR]: I require curl but it's not installed.  Aborting."; exit 1; }

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
datetime=$(date -u +%s)
./speedtest > output.txt
download=`grep Download output.txt |cut -d ':' -f 2|cut -d ' ' -f 2`
upload=`grep Upload output.txt|cut -d ':' -f 2|cut -d ' ' -f 2`
source=`grep 'Testing from' output.txt |cut -d '(' -f2|cut -d ')' -f1`
destination=`grep 'Hosted by' output.txt`

echo "[INFO]: Inserting data into logging database"
payload="${table},home=${source},destination=${destination//\ /_} upload=${upload},download=${download} ${datetime}"
#echo	${payload}
#echo	${influxdb_url}

curl  -X POST ${influxdb_url} --data-binary "$payload"


if [ -e output.txt ];
then
	echo "[INFO]: Cleaning up leftover files"
	rm output.txt
fi





