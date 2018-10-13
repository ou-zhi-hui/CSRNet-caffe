#!/usr/bin/en sh  
DATA1=/home/ozh/share/test
DATA2=/home/ozh/share/test/ShanghaiTech_Crowd_Counting_Dataset/part_A_final/train_data/images/
#rm -rf $DATA1/img_train_den_lmdb  
/home/ozh/share/caffe/build/tools/convert_imageset $DATA2 $DATA1/readPicList/img_train.txt $DATA1/lmdb/images/ 
