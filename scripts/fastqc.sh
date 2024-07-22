#!/bin/bash

## PBS configure
# PBS -N fastqc
# PBS -j oe
# PSB -q batch
# PBS -S /bin/sh
# PBS -l nodes=1:ppn=15

echo "`date +%Y/%m/%d_%H:%M:%S`"  ## Record the date and time
uname -sa  ## Information about the operating system
set -ex  ## Log everything,and quit if there is any error
START=$(date +%s.%N)  

## Source module environment and load tools
source /etc/profile.d/modules.sh
module load fastqc/v0.11.8

## Set variables
fastq_dir=/public/home/shipy3/Amel/input/fastq
output_dir=/public/home/shipy3/Amel/output/fastqc/

## Quality control by FastQC
cd ${fastq_dir}/2/
fastqc -o ${output_dir} -t 2 *fq.gz

cd ${fastq_dir}/OL/
fastqc -o ${output_dir} -t 2 *fq.gz

cd ${fastq_dir}/An2/
fastqc -o ${output_dir} -t 2 *fq.gz


## Unload tools
module unload fastqc/v0.11.8

END=$(date +%s.%N)
Duration=$(echo "$END - $START" | bc)
echo "`date +%Y/%m/%d_%H:%M:%S` Run completed"
echo $Duration
