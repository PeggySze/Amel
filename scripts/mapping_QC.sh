#!/bin/bash

## PBS configure
# PBS -N mapping_QC
# PBS -j oe
# PBS -q batch
# PBS -S /bin/sh
# PBS -l nodes=1:ppn=20

echo "`date +%Y/%m/%d_%H:%M:%S`"  ## Record the date and time
uname -sa  ## Information about the operating system
set -ex  ## Log everything,and quit if there is any error

## Source module envrionment and load tools
source /etc/profile.d/modules.sh
module load samtools/1.9 
module load qualimap/2.2.1 

## Set variables
bam_dir=/public/home/shipy3/Amel/output/STAR/
output_dir=/public/home/shipy3/Amel/output/mapping_QC/

## Sort BAM files
#for i in `seq 579 581`;
#do
#	samtools sort -o ${bam_dir}${i}.sorted.bam -O bam ${bam_dir}${i}Aligned.out.bam
#	rm ${bam_dir}${i}Aligned.out.bam
#done

## Produces RNA alignment metrics by Qualimap
unset DISPLAY

for i in `seq 579 581`;
do
	# BAM QC
	qualimap bamqc -bam ${bam_dir}${i}.sorted.bam \
	--java-mem-size=8G \
	--paint-chromosome-limits \
	-gff /public/home/shipy3/DB/Amel_HAv3.1/annotation/GCF_003254395.2_Amel_HAv3.1_genomic.gtf \
	--collect-overlap-pairs \
	--outside-stats \
	-outdir ${output_dir}${i}/BAM_QC/

	# RNA-seq QC
	qualimap rnaseq -bam ${bam_dir}${i}.sorted.bam -pe \
	--java-mem-size=8G \
	-gtf /public/home/shipy3/DB/Amel_HAv3.1/annotation/GCF_003254395.2_Amel_HAv3.1_genomic.gtf \
	-oc ${output_dir}${i}/RNA-seq_QC \
	-outdir ${output_dir}${i}/RNA-seq_QC 
done

# Multi-sample BAM QC
qualimap multi-bamqc -d ${output_dir}multibamqc_input_config.txt \
-outdir ${output_dir}


# Unload tools 
module unload samtools/1.9 
module unload qualimap/2.2.1 

END=$(date +%s.%N)
Duration=$(echo "$END - $START" | bc)
echo "`date +%Y/%m/%d_%H:%M:%S` Run completed"
echo $Duration
