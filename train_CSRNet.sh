#!/bin/bash
Train_Data_Path=/home/ozh/share/test/lmdb/images
Train_GT_Path=/home/ozh/share/test/lmdb/ground_truth
CAFFE=/home/ozh/share/caffe
TMP=/build/tools/caffe
CAFFE=${CAFFE}${TMP}
SOLVER=./solver.prototxt
GPU_LIST=0
LOG=train.log
## iter ? change ?
WEIGHT=/home/ozh/share/test/VGG_ILSVRC_16_layers.caffemodel

echo "Please input train average loss: "
read average_loss
sed -i '13d' train.prototxt
sed -i "13i \	source:\ \"$Train_Data_Path\"" train.prototxt
sed -i '29d' train.prototxt
sed -i "29i \	source:\ \"$Train_GT_Path\"" train.prototxt
sed -i '4d' solver.prototxt
sed -i "4i average_loss:\ $average_loss" solver.prototxt
if [ ! -x "result_frozen" ]; then mkdir result_frozen; fi
if [ -f $LOG ]; then rm $LOG; fi
$CAFFE train --solver=$SOLVER --gpu=$GPU_LIST --weights=$WEIGHT 2>&1 | tee $LOG
