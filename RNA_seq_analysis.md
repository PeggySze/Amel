### Step 1 : Download data and quality control
- Sample information ( Sample name - Barcode - Sampling position)
  - An2 - 579 - antenna 
  - 2 - 580 - antennal lobe (AL)
  - OL - 581 - antennal lobe (AL)
- quality control by fastqc, trim reads with low quality or adaptors by trimmomatic and check the quality of trimmed reads again.
  - 脚本 ：
  /public/home/shipy3/Amel/bin/fastqc.sh 
  /public/home/shipy3/Amel/bin/trim_reads.sh

### Step 2 : Map reads to reference genome
- reference genome : /public/home/shipy3/DB/Amel_HAv3.1/fasta/GCF_003254395.2_Amel_HAv3.1_genomic.fna
- Mapping reads by STAR 
  - 脚本 ： /public/home/shipy3/Amel/bin/STAR_mapping.sh
- check the mapping quality
  - 579 : 95.34% Uniquely mapped reads
  - 580 : 94.61% Uniquely mapped reads
  - 581 : 96.22% Uniquely mapped reads
  
### Step 3 ：Count reads
- use `htseq-count` to calculate for each feature the number of reads mapping to it
- check the percentage of assigned reads
  - 579 : 77.80%
  - 580 : 73.87%
  - 581 : 72.29%
```R
# Load required packages
library(ggplot2)
library(stringr)

# Load the data
counts.ls <- lapply(579:581,function(i){
	read.table(str_c("/public/home/shipy3/Amel/output/htseq-count/",i,".count"),header=FALSE)
})

# Summarize reads 
stats.ls <- lapply(1:length(counts.ls),function(i){
	df <- data.frame(group=c("assigned reads","reads without feature","ambiguous reads","multi-mapping reads"),value=c(sum(counts.ls[[i]]$V2[1:12320]),counts.ls[[i]]$V2[12321],counts.ls[[i]]$V2[12322],counts.ls[[i]]$V2[12325]))
	df <- df[order(df$value, decreasing = TRUE),]
	df$group <- as.factor(df$group)
	df
})

barcodes <- c("579","580","581")

# Visualize percentage of assigned reads in pie chart
barcodes <- c("579","580","581")
for(i in 1:length(counts.ls)){
	df <- stats.ls[[i]]
	barcode <- barcodes[i]
	myLabel <- paste(as.vector(df$group),"(",round(df$value/sum(df$value)*100,2),"%)",sep="")
	percentage <- paste(round(df$value/sum(df$value)*100,2),"%",sep="")
	pdf(str_c("/public/home/shipy3/Amel/output/htseq-count/",barcode,"_stats.pdf"),width=9)
	p <- ggplot(df,aes(x = "", y = value, fill = group)) +
		geom_bar(stat = "identity") +
		coord_polar(theta = "y") +
		theme(axis.ticks = element_blank()) +
		labs(x = "", y = "") +
		theme(axis.text.x = element_blank()) + 
		scale_fill_discrete(breaks = df$group, labels = myLabel) +
		theme(legend.title = element_blank(), legend.position = "top") + 
		geom_text(aes(label=percentage),position=position_stack(vjust=0.5)) 
	print(p)
	dev.off()
}
```

### Step 4: Normalization of raw counts



