# CSRNet-caffe
This is a caffe implementation of CSRNet for crowd counting.
# Dependencies
```
matlab (2015b)
OpenCV (2.4.13)
```
# How to use?
## caffe build
Because add lmdb2txt tool in caffe
```
cd caffe-CSRNet
mkdir build
cd build
cmake ..
make -j8
```
# 
## prepare data
### download Shanghai dataset: https://drive.google.com/file/d/16dhJn7k4FWVwByRsQAEpl9lwjuV03jVI/view
### generate data list
```
1. cd readPicList
2. python3 readPicList.py -i ../ShanghaiTech_Crowd_Counting_Dataset/part_A_final/train_data/images -o train_list.txt 
3. python3 addSuffix.py --inputfile train_list.txt --outputfile_csv label.list --outputfile_jpg img_train.list
```
### generate density map
copy `readPicList/train_list.txt` to `generate_density` folder and modify `create_gt_train_set.m` corresponding path, then `run create_gt_train_set.m`, the generated density map will be saved in `ground_truth_csv` folder.
## convert ground_truth(.csv) to lmdb
note:**modify the corresponding include and link path in CMakeList file**
eg.`/home/ozh/share/caffe/build/lib`-->`path/to/caffe/build/lib`
```
cd csv2lmdb
mkdir build
cd build
make
cd ../bin
./csv2lmdb --lmdb_path /home/ozh/share/test/lmdb/ground_truth --csv_list ../../readPicList/label.txt --ground_truth_path ../../ShanghaiTech_Crowd_Counting_Dataset/part_A_final/train_data/ground_truth_csv/
```
## convert data(.jpg) to lmdb
`sh create_lmdb.sh`  (modify the corresponding path)
## download pretrain model vgg16
## train
`sh train_CSRNet.sh` (modify the corresponding path)
## test
run crowd_test.m (modify the test_list.txt in deploy.prototxt)
