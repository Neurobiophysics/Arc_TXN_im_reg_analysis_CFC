%%  TXN Analysis Protocol : 1. Image Registration and make the
%%%  intersection map of three day and crop the images.

%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% The analysis is proceed as following
% 1. Load the image of three day
% 2. Image registeration. Reference : HC
% 3. Crop the image and save.

% INPUTS 

% The folder with images (3 stack, Reg, Green, Subtracted).
% 

% OUTPUTS


% MODIFICATION HISTORY : 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 6/11/2018.

%% Parameter setting
clear
[fnm PathName1] = uigetfile('*.tif','Pick cropped image folder to analysis','Multiselect','on');  % Cropped image folder
% imds = imageDatastore(PathName1,'IncludeSubfolders',true,'LabelSource',...
%     'foldernames');       %^%      %#ok
zstack_inter=[4 50;4 50;3 49;4 50;];
zstack=81;
trans_stack=40;
save_path=[PathName1 'Transformed2\'];
mkdir(save_path);
% target_RGB_Image='H:\Image_data\OlympusTPM\20180607\20180607_Arc_oe1_CFC_crop\t01_z01_cell_num0019.tif';
% target_Image='H:\Image_data\OlympusTPM\20180607\20180607_Arc_oe1_CFC_crop_sub\t01_z01_cell_num0019.tif';
%%
mkdir(save_path)
ref_session='Day1_before';
for i=1:length(fnm)
    if ~isempty(findstr(fnm{1,i},ref_session))
        ref=i;
    end
end
%%
 sp_name=split([PathName1 fnm{1,ref}],'\');
 g=1;
for i=zstack_inter(ref,1):zstack_inter(ref,2)
    im(:,:,g)=imread([PathName1 fnm{1,ref}],i);
%     im_lip=imread([PathName1 fnm{1,ref}(5:end)],i);
    if i==zstack_inter(ref,1)
    imwrite(im(:,:,g),[save_path 'T_' sp_name{7,1}],'tif','Compression', 'none');
%     imwrite(im_lip,[save_path 'T_lip_' char(sp_name{6,1})],'tif','Compression', 'none');
    else
    imwrite(im(:,:,g),[save_path 'T_' sp_name{7,1}],'tif','Writemode','Append','Compression', 'none');
%     imwrite(im_lip,[save_path 'T_lip_' char(sp_name{6,1})],'tif','Writemode','Append','Compression', 'none');
    end
    g=g+1;
end
Max_ref_im=max(im,[],3);
%%
i=1;
while i<=size(fnm,2)
    if i~=ref
BaseFile = [PathName1 fnm{1,ref}];
FileToWarp = [PathName1 fnm{1,i}];
% FileToWarp_lip = [PathName1 fnm{1,i}(5:end)];
sp_name=split(FileToWarp,'\');
WarpImageBaseFile = sscanf(FileToWarp,'%c',size(FileToWarp,2)-4);
imginf=imfinfo(FileToWarp);
numstack=size(imginf,1);
timestack=numstack/(zstack);
g=1;
for z=zstack_inter(i,1):zstack_inter(i,2)
    im_warp(:,:,g)=imread(FileToWarp,'tif',z);
g=g+1;
end
% 
% ImageToWarp = imread(FileToWarp,'tif',zstack_inter(i,1)+trans_stack);
% BaseImage = imread(BaseFile,'tif',zstack_inter(ref,1)+trans_stack);
% % 
ImageToWarp = max(im_warp,[],3);
BaseImage = Max_ref_im;

tempWarp = double(ImageToWarp);
tempBase = double(BaseImage);

tempWarp = tempWarp./max(max(tempWarp))*3;
tempBase = tempBase./max(max(tempBase))*3;

% Select the control points.
h = cpselect(tempWarp, tempBase);
uiwait(msgbox('Click OK after closing the CPSELECT window.','Waiting...'))

movingPoints = cpcorr(movingPoints, fixedPoints,tempWarp,tempBase);
tform2 = maketform('projective',movingPoints, fixedPoints);

for z=zstack_inter(i,1):zstack_inter(i,2)


    ImageToWarp = imread(FileToWarp,'tif',z);
[transVis xdata ydata] = imtransform(ImageToWarp, tform2);
transVisWithOffset = imtransform(ImageToWarp, tform2, 'XData', [1 (size(ImageToWarp,2)+tform2.tdata.T(3,1))],'YData', [1 (size(ImageToWarp,1)+ tform2.tdata.T(3,2))]);
transVisBuffrd = uint16(zeros(size(BaseImage)));
transVisBuffrd(1:size(transVisWithOffset,1),1:size(transVisWithOffset,2)) = transVisWithOffset;
Transformation_Matrix=tform2.tdata.T(1:2,1:2);
Translation_Vector=tform2.tdata.T(3,1:2)';
transVisBuffrd = transVisBuffrd((1:size(ImageToWarp,1)), (1:size(ImageToWarp,2)));

imwrite(transVisBuffrd,[save_path 'T_' char(sp_name{7,1})],'tif','Writemode','Append','Compression', 'none');

% ImageToWarp = imread(FileToWarp_lip,'tif',z);
% [transVis xdata ydata] = imtransform(ImageToWarp, tform2);
% transVisWithOffset = imtransform(ImageToWarp, tform2, 'XData', [1 (size(ImageToWarp,2)+tform2.tdata.T(3,1))],'YData', [1 (size(ImageToWarp,1)+ tform2.tdata.T(3,2))]);
% transVisBuffrd = uint16(zeros(size(BaseImage)));
% transVisBuffrd(1:size(transVisWithOffset,1),1:size(transVisWithOffset,2)) = transVisWithOffset;
% Transformation_Matrix=tform2.tdata.T(1:2,1:2);
% Translation_Vector=tform2.tdata.T(3,1:2)';
% transVisBuffrd = transVisBuffrd((1:size(ImageToWarp,1)), (1:size(ImageToWarp,2)));
% 
% imwrite(transVisBuffrd,[save_path 'T_lip_' char(sp_name{6,1})],'tif','Writemode','Append','Compression', 'none');
 
end

save([WarpImageBaseFile,'T.mat'], 'tform2');
    end
    i=i+1;
end