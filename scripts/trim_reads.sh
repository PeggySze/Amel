#!/bin/bash

## PBS configure
# PBS -N trim_reads
# PBS -j oe
# PSB -q batch
# PBS -S /bin/sh
# PBS -l nodes=1:ppn=20

echo "`date +%Y/%m/%d_%H:%M:%S`"  ## Record the date and time
uname -sa  ## Information about the operating system
set -ex  ## Log everything,and quit if there is any error
START=$(date +%s.%N)  

## Source module environment and load tools
source /etc/profile.d/modules.sh
module load trimmomatic/0.39
module load fastqc/v0.11.8

## Set variables
fastq_dir=/public/home/shipy3/Amel/input/fastq/
output_dir=/public/home/shipy3/Amel/output/trimmed_fastqc/

## Trim adaptors and low quality reads
for i in `seq 579 581`;
do
	java -jar ~/software/trimmomatic/0.39/trimmomatic-0.39.jar PE -phred33 -trimlog ${fastq_dir}${i}_trimlog \
	-summary ${fastq_dir}${i}_trim_summary ${fastq_dir}DP8400012190BL_L01_${i}_1.fq.gz ${fastq_dir}DP8400012190BL_L01_${i}_2.fq.gz \
	${fastq_dir}trimmed_${i}_1P.fastq.gz ${fastq_dir}trimmed_${i}_1U.fastq.gz \
	${fastq_dir}trimmed_${i}_2P.fastq.gz ${fastq_dir}trimmed_${i}_2U.fastq.gz \
	ILLUMINACLIP:~/software/trimmomatic/0.39/adapters/TruSeq3-PE.fa:2:30:10 \
	SLIDINGWINDOW:5:20 LEADING:10 TRAILING:10 MINLEN:50 ;
done

## Quality control after trimming
for i in `seq 579 581`;
do
	fastqc -o ${output_dir} -t 2 ${fastq_dir}trimmed_${i}_1P.fastq.gz ${fastq_dir}trimmed_${i}_2P.fastq.gz
done

## Unload tools 
module unload trimmomatic/0.39
module unload fastqc/v0.11.8

END=$(date +%s.%N)
Duration=$(echo "$END - $START" | bc)
echo "`date +%Y/%m/%d_%H:%M:%S` Run completed"
echo $Duration
