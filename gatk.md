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
```
