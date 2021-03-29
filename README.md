# notes prinseq, trimmomatic 及 seqtk

```
#直接用fastq-dump下载
fastq-dump --split-files SRR519926

看一下上述的文件如何被gzip压缩的那个替换。

# 测试解压时间分别是多少。

# - Airy: 2.1 seconds

# - Grit: 2.8 seconds

# - Apollo: 3.6 seconds

# - Peppy: 6.5 seconds

time gunzip *.gz



# 把两个文件打包到一个存档里

tar cf mydata.tar *.fastq

gzip mydata.tar



# 上边两个命令可以结合到一个命令中。

tar cfzv mydata.tar.gz *.fastq



# 移除fastq文件

rm -f *.fastq

ls -l



# 拆包存档，提取文件。

tar xzvf mydata.tar.gz



# 你可以存档整个目录树。打包整个 lecture 7文件夹

cd ..

tar cfzv lec7.tar.gz lec7



# 用 t 罗列存档中有什么。

tar tf lec7.tar.gz



# 把存档解压到不同路径下。

mkdir ~/edu/tmp

mv lec7.tar.gz ~/edu/tmp

cd ~/edu/tmp

tar xzvf lec7.tar.gz



# Under Linux do the following:
# echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
# source ~/.bashrc

# Link the fastqc under an "shortcut" in ~/bin
ln -s ~/src/FastQC/fastqc ~/bin/fastqc


Install prinseq
# We need to also pass the -L flag since this site uses link redirects and
# we want to follow those
curl -OL http://downloads.sourceforge.net/project/prinseq/standalone/prinseq-lite-0.20.4.tar.gz


# 安装prinseq

# 我们需要加 -L ，因为这个网址使用的链接重定向，而我们要下载的是这个。

curl -OL http://downloads.sourceforge.net/project/prinseq/standalone/prinseq-lite-0.20.4.tar.gz
tar zxvf prinseq-lite-0.20.4.tar.gz

# 进入文件夹，并阅读操作指南。

# 找到文件README。跟着它说的去做。

cd prinseq-lite-0.20.4

# Make the script executable.
chmod +x prinseq-lite.pl

#建立连接到 ~/bin 文件夹。

ln -s ~/src/prinseq-lite-0.20.4/prinseq-lite.pl ~/bin/prinseq-lite

# Now you have prinseq running anywhere on your system.
prinseq-lite


# 安装trimmomatic

cd ~/src

curl -O http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip

unzip Trimmomatic-0.32.zip

cd Trimmomatic-0.32



# 哎呀，这里信息不多，你可以到这查看一下手册：

# http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

# 它的运行用户不友好。非常感谢！

java -jar trimmomatic-0.32.jar



# 我们写一个脚本来替代我们运行。

# 用Komodo或者命令行创建一个脚本，包含如下所示的命令行 :

# 你也可以通过命令行来达成



echo '#!/bin/bash' > ~/bin/trimmomatic

echo 'java -jar ~/src/Trimmomatic-0.32/trimmomatic-0.32.jar $@' >> ~/bin/trimmomatic

chmod +x ~/bin/trimmomatic



# 看，成功了！

trimmomatic

# 运行prinseq，从右往左，5碱基一个窗口，修剪碱基。

prinseq-lite -fastq SRR519926_1.fastq -trim_qual_right 30 -trim_qual_window 4 -min_len 35 -out_good prinseq_1

^C
(base) ubuntu@VM-0-17-ubuntu:~/edu/lec7$ ls
mydata.tar.gz			    SRR519926_1_prinseq_bad_ew0l.fastq
prinseq_1.fastq			    SRR519926_1_prinseq_bad_vkeM.fastq
SRR519926_1.fastq		    SRR519926_2.fastq
SRR519926_1_fastqc.html		    SRR519926_2_fastqc.html
SRR519926_1_fastqc.zip		    SRR519926_2_fastqc.zip
SRR519926_1_prinseq_bad_3Ei6.fastq

# Trimmomatic则有不同的参数设置和哲学。参数要用空格分割。Parameters need to be space separated words 子参数则用冒号分割。基本上他们参数格式自成一家。

trimmomatic SE -phred33 SRR519926_1.fastq trimmomatic_1.fq SLIDINGWINDOW:4:30 MINLEN:35 TRAILING:3

conda activate wes
(wes) ubuntu@VM-0-17-ubuntu:~/edu/lec7$ trimmomatic SE -phred33 SRR519926_1.fastq trimmomatic_1.fq SLIDINGWINDOW:4:30 MINLEN:35 TRAILING:3
TrimmomaticSE: Started with arguments:
 -phred33 SRR519926_1.fastq trimmomatic_1.fq SLIDINGWINDOW:4:30 MINLEN:35 TRAILING:3
Automatically using 4 threads
Input Reads: 400596 Surviving: 340207 (84.93%) Dropped: 60389 (15.07%)
TrimmomaticSE: Completed successfully
(wes) ubuntu@VM-0-17-ubuntu:~/edu/lec7$ 


fastqc SRR519926_1.fastq prinseq_1.fq trimmomatic_1.fq



# 默认情况下，fastqc在图中使用分组，而隐藏详细信息。

fastqc --nogroup SRR519926_1.fastq prinseq_1.fq trimmomatic_1.fq



#要批量处理文件，可以使用简单的shell循环结构。

for name in *.fastq; do echo $name; done

#*下边两个是脚本

在你的~/bin 文件夹创建trimmomatic文件：



#!/bin/bash

# 上一行是告诉shell，用bash执行程序。

# 下面行中的 $@ 表示把所有的参数传递到程序。

java -jar ~/src/Trimmomatic-0.32/trimmomatic-0.32.jar $@



构造简单循环的例子：



#!/bin/bash

# 这个脚本会把目录下的所有fastq文件进行修剪。

for name in *.fastq

do

echo "*** currently processing file $name, saving to trimmed-$name"

trimmomatic SE -phred33 $name trimmed-$name SLIDINGWINDOW:4:30 MINLEN:35 TRAILING:3

echo "*** done"

done

# 现在，运行fastqc报告。

# 你可以在这添加更多的命令。

fastqc trimmed-*.fastq






























































