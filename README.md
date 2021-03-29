# notes

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




















