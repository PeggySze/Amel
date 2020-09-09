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
```R
# Load required packages
library(dplyr)
library(stringr)
library(pheatmap)
library(stats)
library(ggplot2)
library(ggfortify)
library(corrplot)

# calculate gene length (define gene length as total length of exons)
Amel_HAv3.1_exons <- read.table("/public/home/shipy3/DB/Amel_HAv3.1/annotation/Amel_HAv3.1_exon.txt",header=FALSE)
colnames(Amel_HAv3.1_exons) <- c("feature","start","end","gene_id")
Amel_HAv3.1_exons$length <- Amel_HAv3.1_exons$end - Amel_HAv3.1_exons$start + 1
gene_lens <- Amel_HAv3.1_exons %>%
	group_by(gene_id) %>%
	summarise(
		length=sum(length)
		)

# read raw counts into R
counts.ls <- lapply(579:581,function(i){
	df <- read.table(str_c("/public/home/shipy3/Amel/output/htseq-count/",i,".count"),header=FALSE)
	df <- df[c(-1,-12321:-12325),]
	colnames(df) <- c("gene_id",str_c("sample_",i))
	df
})

counts <- cbind(counts.ls[[1]],counts.ls[[2]][,2],counts.ls[[3]][,2])
colnames(counts) <- c("gene_id","sample_579","sample_580","sample_581")
counts <- merge(counts,gene_lens)
rownames(counts) <- counts$gene_id

## Computing TPM
# first step: get gene length normalized values 
geneLengths <- counts$length
rpk <- apply(subset(counts, select = c(-length,-gene_id)), 2, 
              function(x) x/(geneLengths/1000))

# second step: normalize using rpk values
tpm <- apply(rpk, 2, function(x) x / sum(as.numeric(x)) * 10^6)

### Exploratory analysis of the read count
## Clustering
# select most variable genes to do the clustering and visualization
#compute the variance of each gene across samples
V <- apply(tpm, 1, var)

#sort the results by variance in decreasing order and select the top 100 genes 
selectedGenes <- names(V[order(V, decreasing = T)][1:100])

# produce a heatmap where samples and genes are clustered
pdf("/public/home/shipy3/Amel/output/htseq-count/top100_HVG_heatmap.pdf")
pheatmap(tpm[selectedGenes,], scale = 'row', show_rownames = FALSE,angle_col=0)
dev.off()

## Correlation plots
# compute pairwise correlation scores between every pair of samples
correlationMatrix <- cor(tpm)

# draw correlation plots
pdf("/public/home/shipy3/Amel/output/htseq-count/sample_correlation.pdf")
corrplot(correlationMatrix, order = 'hclust')
corrplot(correlationMatrix, order = 'hclust',addCoef.col = 'white')
pheatmap(correlationMatrix)
dev.off()
```


