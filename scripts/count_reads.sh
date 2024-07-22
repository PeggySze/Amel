#!/bin/bash

## PBS configure
# PBS -N count_reads
# PBS -j oe
# PSB -q batch
# PBS -S /bin/sh
# PBS -l nodes=1:ppn=20

echo "`date +%Y/%m/%d_%H:%M:%S`"  ## Record the date and time
uname -sa  ## Information about the operating system
set -ex  ## Log everything,and quit if there is any error
START=$(date +%s.%N)  

## Set variables
bam_dir=/public/home/shipy3/Amel/output/STAR/
htseq_count_output_dir=/public/home/shipy3/Amel/output/htseq-count/
featureCounts_output_dir=/public/home/shipy3/Amel/output/featureCounts/
gtf_file=/public/home/shipy3/DB/Amel_HAv3.1/annotation/GCF_003254395.2_Amel_HAv3.1_genomic.gtf

## Count reads by htseq-count
for i in `seq 579 581`;
do
	~/miniconda3/conda_software/bin/htseq-count -f bam -r pos -s no \
	-a 10 -t exon -i gene_id -m union \
	${bam_dir}${i}.sorted.bam \
	${gtf_file} \
	> ${htseq_count_output_dir}${i}.count ;
done


## Count reads by featureCounts
for i in `seq 579 581`;
do
	/public/home/shipy3/miniconda3/bin/featureCounts -T 5 -p -t exon -g gene_id \
	-a ${gtf_file} \
	-o ${featureCounts_output_dir}${i}.count \
	${bam_dir}${i}.sorted.bam 
done


END=$(date +%s.%N)
Duration=$(echo "$END - $START" | bc)
echo "`date +%Y/%m/%d_%H:%M:%S` Run completed"
echo $Duration
