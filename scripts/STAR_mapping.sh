#!/bin/bash

## PBS configure
# PBS -N STAR_mapping
# PBS -j oe
# PSB -q batch
# PBS -S /bin/sh
# PBS -l nodes=1:ppn=20

echo "`date +%Y/%m/%d_%H:%M:%S`"  ## Record the date and time
uname -sa  ## Information about the operating system
set -ex  ## Log everything,and quit if there is any error
START=$(date +%s.%N) 

## Set variables
trimmed_fastq_dir=/public/home/shipy3/Amel/input/fastq/
output_dir=/public/home/shipy3/Amel/output/STAR/

## Mapping reads to the genome
for i in `seq 579 581`;
do
	/public/home/jinxu/software/STAR-master/bin/Linux_x86_64/STAR --runThreadN 8 \
	--genomeDir /public/home/shipy3/DB/Amel_HAv3.1/STAR_index \
	--readFilesIn ${trimmed_fastq_dir}trimmed_${i}_1P.fastq.gz ${trimmed_fastq_dir}trimmed_${i}_2P.fastq.gz \
	--readFilesCommand zcat \
	--outFileNamePrefix ${output_dir}${i} \
	--outSAMtype BAM Unsorted
done


END=$(date +%s.%N)
Duration=$(echo "$END - $START" | bc)
echo "`date +%Y/%m/%d_%H:%M:%S` Run completed"
echo $Duration
