```
# 一个个地下载hg19的染色体
for i in $(seq 1 22) X Y M;
do echo $i;
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr${i}.fa.gz;
done

gunzip *.gz

# 用cat按照染色体的顺序拼接起来，因为GATK后面的一些步骤对染色体顺序要求非常变态，如果下载整个hg19，很难保证染色体顺序是1-22，X,Y,M
for i in $(seq 1 22) X Y M;
do cat chr${i}.fa >> hg19.fasta;
done

rm -fr chr*.fasta
```

```
#BWA: Map to Reference
#建立参考序列索引
$ bwa index -a bwtsw ref.fa

参数-a用于指定建立索引的算法：

bwtsw 适用于>10M
is 适用于参考序列<2G (默认-a is)
可以不指定-a参数，bwa index会根据基因组大小来自动选择合适的索引方法

2.序列比对
$ bwa mem ref.fa sample_1.fq sample_2.fq -R '@RG\tID:sample\tLB:sample\tSM:sample\tPL:ILLUMINA' \
	2>sample_map.log | samtools sort -@ 20 -O bam -o sample.sorted.bam 1>sample_sort.log 2>&1
#-R 选项为必须选项，用于定义头文件中的SAM/BAM文件中的read group和sample信息
#> The file must have a proper bam header with read groups. Each read group must contain the platform (PL) and sample (SM) tags. 
> For the platform value, we currently support 454, LS454, Illumina, Solid, ABI_Solid, and CG (all case-insensitive)
> 
> The GATK requires several read group fields to be present in input files and will fail with errors if this requirement is not satisfied
> 
> ID：输入reads集的ID号； LB： reads集的文库名； SM：样本名称； PL：测序平台
>

#查看SAM/BAM文件中的read group和sample信息：

$ samtools view -H /path/to/my.bam | grep '^@RG'
@RG ID:0    PL:solid    PU:Solid0044_20080829_1_Pilot1_Ceph_12414_B_lib_1_2Kb_MP_Pilot1_Ceph_12414_B_lib_1_2Kb_MP   LB:Lib1 PI:2750 DT:2008-08-28T20:00:00-0400 SM:NA12414  CN:bcm
@RG ID:1    PL:solid    PU:0083_BCM_20080719_1_Pilot1_Ceph_12414_B_lib_1_2Kb_MP_Pilot1_Ceph_12414_B_lib_1_2Kb_MP    LB:Lib1 PI:2750 DT:2008-07-18T20:00:00-0400 SM:NA12414  CN:bcm
@RG ID:2    PL:LS454    PU:R_2008_10_02_06_06_12_FLX01080312_retry  LB:HL#01_NA11881    PI:0    SM:NA11881  CN:454MSC
@RG ID:3    PL:LS454    PU:R_2008_10_02_06_07_08_rig19_retry    LB:HL#01_NA11881    PI:0    SM:NA11881  CN:454MSC
@RG ID:4    PL:LS454    PU:R_2008_10_02_17_50_32_FLX03080339_retry  LB:HL#01_NA11881    PI:0    SM:NA11881  CN:454MSC
```

```
read group信息不仅会加在头信息部分，也会在比对结果的每条记录里添加一个 RG:Z:* 标签

$ samtools view /path/to/my.bam | grep '^@RG'
EAS139_44:2:61:681:18781    35  1   1   0   51M =   9   59  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA B<>;==?=?<==?=?=>>?>><=<?=?8<=?>?<:=?>?<==?=>:;<?:= RG:Z:4  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31
EAS139_44:7:84:1300:7601    35  1   1   0   51M =   12  62  TAACCCTAAGCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA G<>;==?=?&=>?=?<==?>?<>>?=?<==?>?<==?>?1==@>?;<=><; RG:Z:3  MF:i:18 Aq:i:0  NM:i:1  UQ:i:5  H0:i:0  H1:i:85
EAS139_44:8:59:118:13881    35  1   1   0   51M =   2   52  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA @<>;<=?=?==>?>?<==?=><=>?-?;=>?:><==?7?;<>?5?<<=>:; RG:Z:1  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31
EAS139_46:3:75:1326:2391    35  1   1   0   51M =   12  62  TAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAACCCTAA @<>==>?>@???B>A>?>A?A>??A?@>?@A?@;??A>@7>?>>@:>=@;@ RG:Z:0  MF:i:18 Aq:i:0  NM:i:0  UQ:i:0  H0:i:85 H1:i:31

若原始SAM/BAM文件没有read group和sample信息，可以通过AddOrReplaceReadGroups添加这部分信息

$ java -jar picard.jar AddOrReplaceReadGroups \
      I=input.bam \
      O=output.bam \
      RGID=4 \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=20
      
前期处理
在进行本部分的操作之前先要做好以下两部的准备工作

1、创建GATK索引。用Samtools为参考序列创建一个索引，这是为方便GATK能够快速地获取fasta上的任何序列做准备
$ samtools faidx database/chr17.fa	# 该命令会在chr17.fa所在目录下创建一个chr17.fai索引文件

2、生成.dict文件

$ gatk CreateSequenceDictionary -R database/chr17.fa -O database/chr17.dict

GATK4的调用语法：

gatk [--java-options "-Xmx4G"] ToolName [GATK args]

duplicates的产生原因 :Optical duplicates（光学重复）
Sister duplicates
PCR duplicates（PCR重复）
Cluster duplicates
Optical duplicates（光学重复）

探究samtools和picard去除read duplicates的方法
1、samtools

samtools 去除 duplicates 使用 rmdup

$ samtools rmdup [-sS] <input.srt.bam> <out.bam>

2、picard

picard对于单端或者双端测序数据并没有区分参数，可以用同一个命令！

对应单端测序，picard的处理结果与samtools rmdup没有差别，不过这个java软件的缺点就是奇慢无比

# 使用GATK命令
$ gatk SortSam -I mapping/T.chr17.sam -O preprocess/T.chr17.sort.bam -R database/chr17.fa -SO coordinate --CREATE_INDEX
# 使用picard命令
$ java -jar picard.jar SortSam \
      I=input.bam \
      O=sorted.bam \
      SORT_ORDER=coordinate
    
    
$ samtools view -H /path/to/my.bam
@HD     VN:1.0  GO:none SO:coordinate
@SQ     SN:1    LN:247249719
@SQ     SN:2    LN:242951149
@SQ     SN:3    LN:199501827
@SQ     SN:4    LN:191273063
@SQ     SN:5    LN:180857866
@SQ     SN:6    LN:170899992
@SQ     SN:7    LN:158821424


2、标记重复（Markduplicates）

标记文库中的重复

gatk MarkDuplicates -I preprocess/T.chr17.sort.bam -O preprocess/T.chr17.markdup.bam -M preprocess/T.chr17.metrics --CREATE_INDEX

质量值校正
# 下载known-site的VCF文件，到Ensembl上下载
$ wget -c -P Ref/mouse/mm10/vcf ftp://ftp.ensembl.org/pub/release-93/variation/vcf/mus_musculus/mus_musculus.vcf.gz >download.log &
$ cd Ref/mouse/mm10/vcf && gunzip mus_musculus.vcf.gz && mv mus_musculus.vcf dbsnp_150.mm10.vcf
# 建好vcf文件的索引，需要用到GATK工具集中的IndexFeatureFile，该命令会在指定的vcf文件的相同路径下生成一个以".idx"为后缀的文件
$ gatk IndexFeatureFile -F dbsnp_150.mm10.vcf

# 建立较正模型
$ gatk BaseRecalibrator -R Ref/mouse/mm10/bwa/mm10.fa -I PharmacogenomicsDB/mouse/SAM/ERR118300.enriched.markdup.bam -O \
PharmacogenomicsDB/mouse/SAM/ERR118300.recal.table --known-sites Ref/mouse/mm10/vcf/dbsnp_150.mm10.vcf

# 质量校正
$ gatk ApplyBQSR -R Ref/mouse/mm10/bwa/mm10.fa -I PharmacogenomicsDB/mouse/SAM/ERR118300.enriched.markdup.bam -bqsr \
PharmacogenomicsDB/mouse/SAM/ERR118300.recal.table -O PharmacogenomicsDB/mouse/SAM/ERR118300.recal.bam












