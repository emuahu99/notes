 Quality control: pattern matching and adapter trimming


```
*在正则表达式里，行开头用^表示

cat SRR519926_1.fastq | egrep "^ATG" --color=always | head

#搜索行末为ATG的行

#*在正则表达式里，$表示匹配输入字符串的结束位置

cat SRR519926_1.fastq | egrep "ATG\$" --color=always | head

# 搜索TAATA或TATTA模式，这是一个字符范围

cat SRR519926_1.fastq | egrep "TA[A,T]TA" --color=always | head
```

