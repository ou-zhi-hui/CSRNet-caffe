clc; clear all,close all;
dataset = 'train';
path=['W:/crowd_counting/dataset_ours/' dataset '_data' '/images/'];
path_resize=['W:/crowd_counting/dataset_ours/' dataset '_data' '/images_resize_1024x576/'];
gt_path=['W:/crowd_counting/dataset_ours/' dataset '_data' '/ground_truth/'];
gt_path_csv=['W:/crowd_counting/dataset_ours/' dataset '_data' '/ground_truth_csv_1024x576/'];
mkdir(gt_path_csv);
mkdir(path_resize);
fid=fopen(['W:/crowd_counting/CSRNet/CSRNet-caffe/readDataName/nameList_' dataset '.txt']);
tline = fgetl(fid);
i=0;
while ischar(tline)
    i=i+1;
    load(strcat(gt_path,tline,'.mat')) ;
    input_img_name = strcat(path,tline,'.jpg');
    im = imread(input_img_name);
    
%     im_resized=imresize(im,1/2,'bicubic');%原图下采样2倍
    im_resized=imresize(im,[576,1024],'bicubic');%resize成1080p
    imwrite(im_resized,([path_resize tline '.jpg']));
    
    [h, w, c] = size(im);%使用原图
    if (c == 3)
        im = rgb2gray(im);aa
    end  
    
    annPoints =  image_info{1}.location; 
    im_density = get_density_map_gaussian(im,annPoints);
    im_density=imresize(im_density,[576,1024],'bicubic')*(w*h/(576*1024));%resize成1080p
    im_density_resized=imresize(im_density,1/8,'bicubic')*64.0;%下采样8倍
    csvwrite([gt_path_csv tline '.csv'], im_density_resized);
    disp(['Pic:',num2str(i),' ',tline,'  label:',num2str(image_info{1}.num),'  resize:',num2str(sum(sum(im_density_resized)))]);
    tline = fgetl(fid);
end
fclose(fid);
