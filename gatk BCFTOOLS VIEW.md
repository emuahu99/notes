##制作config文件
```
for i in $(ls *.bam)

do
    sample=$(basename $i|sed s/.bam//g)	
    echo ${sample} >> config
done

#标记PCR重复reads
cat config |while read id
do
    arr=($id)
    sample=${arr[0]}
#mark dupulicates
    $gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" MarkDuplicates \
    -I $dir/align/$sample.bam \
    -O $dir/align/${sample}_marked.bam \
    -M $dir/align/$sample.metrics \
    1>log.mark 2>&1
    
    
    
BCFTOOLS VIEW 可以用于查看VCF或BCF文件，VCF/BCF互相转换，提取子集，或进行过滤，用法如下：

bcftools view [options] <in.vcf.gz> [region1 [...]]
# 只针对压缩的VCF文件，即vcf.gz，若不是压缩格式，先转换成压缩格式，比如现在有一个文件，xxx.vcf，使用bgzip进行压缩，
> bgzip xxx.vcf
# 得到xxx.vcf.gz，生成索引
> bcftools index -t xxx.vcf.gz
# 得到xxx.vcf.gz.tbi，即可开始使用BCFTOOLS VIEW进行操作














