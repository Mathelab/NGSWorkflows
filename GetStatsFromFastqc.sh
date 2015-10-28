#!/bin/bash
# Ewy Mathe
# 10/27/2015


function usage {
	cat <<EOF
Usage: ./GetStatsFromFastqc.sh samples projectname

Where "samples" is a simple text file listing all the processed files in the project.  Be sure to include the full path, do not include "_fastqc" suffix (e.g. mydir/sample01)

projectname is a string for the project name

The script will output a tab delimited text file named "projectname.txt" with some stats grabbed from fastqc output
EOF
}

cd=$(pwd)"/"

infile=""
projectname=""

function parse_cmdline {
	infile="$1"
	projectname="$2"
	echo "Chips File: $infile"
	# Make sure sample file is provided
	if [[ "$infile" == "" ]] ;then
		echo -e "[Error] No sample file provided\n"
		usage
		exit 1
	fi
	if [[ "$projectname" == "" ]]; then
		echo -e "[Error] No project name provided\n"
		usage
		exit 1
	fi
	# Make sure sample file exists
	if [[ ! -e $infile ]]; then
		echo -e "[Error] $infile does not exist\n"
		usage
		exit 1
	fi
	echo "Processing $infile"
	echo "Creating $projectname.xls"
	# If project file exists, delete it
	if [[ -e ${projectname}.txt ]]; then
		echo "Overwriting ${projectname}.txt"
		rm ${projectname}.txt
	fi
}

parse_cmdline $@

cat $infile | while read -a line;
do
	#$(echo "/data/mathee/SEQ/SCRIPTS/DNAse2TF/calcDFT/calcDFT /data/mathee/SEQ/SCRIPTS/MAPPABILITY2/mm9fa/ ${line[2]}" >> rundft)
	echo "Processing ${line}_fastqc"
	if [[ ! -d ${line}_fastqc ]]; then
		unzip ${line}_fastqc.zip
	fi
	filename=$(grep "Filename" ${line}_fastqc/fastqc_data.txt | sed 's/Filename\t//')
	echo "$filename"
	numreads=$(grep "Total Sequences" ${line}_fastqc/fastqc_data.txt | sed 's/Total Sequences\t//')
	echo "$numreads"
	qcstats=$(grep "Basic Statistics" ${line}_fastqc/fastqc_data.txt | sed 's/>>Basic Statistics\t//')
	echo "$qcstats"
	len=$(grep "Sequence length" ${line}_fastqc/fastqc_data.txt | sed 's/Sequence length\t//')
	echo "$len"
	echo -e $filename"\t"$qcstats"\t"$len"\t"$numreads >> ${projectname}.txt
done


