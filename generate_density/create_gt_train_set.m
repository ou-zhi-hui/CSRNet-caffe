clc; clear all,close all;
dataset = 'train';
path=['X:/test/ShanghaiTech_Crowd_Counting_Dataset/part_A_final/' dataset '_data' '/images/'];
gt_path=['X:/test/ShanghaiTech_Crowd_Counting_Dataset/part_A_final/' dataset '_data' '/ground_truth/'];
gt_path_csv=['X:/test/ShanghaiTech_Crowd_Counting_Dataset/part_A_final/' dataset '_data' '/ground_truth_csv/'];
mkdir(gt_path_csv);
fid=fopen('train_list.txt');
tline = fgetl(fid);
i=0;
while ischar(tline)
    i=i+1;
    load(strcat(gt_path,'GT_',tline,'.mat')) ;
    input_img_name = strcat(path,tline,'.jpg');
    im = imread(input_img_name);
    
    [h, w, c] = size(im);
    if (c == 3)
        im = rgb2gray(im);
    end  
    
    annPoints =  image_info{1}.location; 
    im_density = get_density_map_gaussian(im,annPoints);
    im_density_resized=imresize(im_density,1/8,'bicubic')*64.0;%ÏÂ²ÉÑù8±¶
    csvwrite([gt_path_csv tline '.csv'], im_density_resized);
    disp(['Pic:',num2str(i),' ',tline,'  label:',num2str(image_info{1}.number),'  resize:',num2str(sum(sum(im_density_resized)))]);
    tline = fgetl(fid);
end
fclose(fid);
