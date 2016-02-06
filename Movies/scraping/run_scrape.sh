#!/bin/bash
word=$1
yr_start=$2
yr_end=$3

for y in $(eval "echo {$yr_start..$yr_end}")
do 
	echo $y
	python2 times_scrape.py $word $y
done
