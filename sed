示例1：去除特定的字符

方法：将所有 - 替换为空

for file in `ls | grep .jpg`
do
 newfile=`echo $file | sed 's/-//g'`
 mv $file $newfile
done

for file in `ls | grep .bam`
do
 newfile=`echo $file | sed 's/val_1.fq.gz.bam/1.fq.gz.bam/g'`
 mv $file $newfile
done
