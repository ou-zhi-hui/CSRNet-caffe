clear all; close all;
%lib = 'LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libopencv_core.so.2.4:/usr/lib/x86_64-linux-gnu/libopencv_highgui.so.2.4:/usr/lib/x86_64-linux-gnu/libopencv_imgproc.so.2.4 ';
lib='';
%'LD_LIBRARY_PATH=/your/hdf5/path/hdf5-1.8.14/build/install/lib/:/data1/install/cuda-7.5/lib64/:/usr/local/lib/:/d/install/mdb-mdb/libraries/liblmdb:/d/install/leveldb-1.15.0:/usr/local/opencv-2.4.10/lib/:/d/home/darwinli/tools/cuda-7.5/lib64/:/d/home/darwinli/tools/anaconda/lib:/d/runtime/gcc-4.8.4/lib64:/d/runtime/cudnn-7.5-linux-x64-v5.0/lib64/:/data1/install/cuda-7.5/lib64/:/usr/local/lib/:/d/install/mdb-mdb/libraries/liblmdb:/d/install/leveldb-1.15.0:/usr/local/opencv-2.4.10/lib/:/d/home/darwinli/tools/cuda-7.5/lib64/:/d/home/darwinli/tools/anaconda/lib:/d/runtime/gcc-4.8.4/lib64:/d/runtime/cudnn-7.5-linux-x64-v5.0/lib64/:/d/runtime/nccl-1.2.3-1-cuda7.5/lib ';
caffe_path = '/home/ozh/share/caffe/build/tools/extract_features';
caffe_model = '/home/ozh/share/test/result/shanghaiA.caffemodel';
lmdb2txt = '/home/ozh/share/caffe/build/tools/lmdb2txt';
root_dir = '/home/ozh/share/test/ShanghaiTech_Crowd_Counting_Dataset/part_A_final/';
image_dir = [root_dir 'test_data/images_resize/'];
image_list = dir([image_dir '*.jpg']); 
gt_dir = [root_dir 'test_data/ground_truth/'];
gt_list = dir([gt_dir '*.mat']);
test_dir = [root_dir 'test_data/test_img/'];
dataPrepare=false;
if exist(test_dir)
    dataPrepare=true;
    %rmdir(test_dir, 's')
end
if exist('estdmap.db')
   rmdir('estdmap.db', 's')
   delete('estdmap.txt')
end
if dataPrepare==false
    mkdir(test_dir);
    fid = fopen([test_dir 'list.txt'], 'w');
else
    fid = fopen([test_dir 'list.txt'], 'r');
end
gpu_id = 0;

nImg = length(image_list);
gtcc = zeros(nImg,1);
for kk = 1:nImg
  test_image = imread([image_dir image_list(kk).name]);
  load([gt_dir gt_list(kk).name]);
  if dataPrepare==false
    test_img = test_image;
     imsize_ori = size(test_img);
     %% deconvolution
     test_img = imresize(test_img, [floor(imsize_ori(1)/8)*8 floor(imsize_ori(2)/8)*8]);
    imwrite(test_img, [test_dir image_list(kk).name]);

    fprintf(fid, '%s\n', [test_dir image_list(kk).name]);
  end
  gtcc(kk) = image_info{1}.num;
end
fclose(fid);
tic;
%disp([lib caffe_path ' ' caffe_model ' deploy.prototxt estdmap estdmap.db ' num2str(nImg) ' lmdb GPU ' num2str(gpu_id)])
system([lib caffe_path ' ' caffe_model ' deploy.prototxt estdmap estdmap.db ' num2str(nImg) ' lmdb GPU ' num2str(gpu_id)]);
ttt = toc;
disp(['time = ' num2str(ttt*1000)])
system([lmdb2txt ' estdmap.db >> estdmap.txt']);
cc = dlmread('estdmap.txt');
cc = sum(cc(:,:),2);%real
ccgtcc = [cc gtcc abs(cc-gtcc)]
MAE = mean(abs(cc-gtcc))
MSE = mean((cc-gtcc).^2)^(0.5)
