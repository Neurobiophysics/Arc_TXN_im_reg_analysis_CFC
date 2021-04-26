%  Image enhancement code
%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% This code enhances the signal with specific PSF size.

% INPUTS 

% Image stack
% 

% OUTPUTS
% Filtered image stack

% MODIFICATION HISTORY : 
%     2019.01.23.
% Modification on filtered image (3D Gaussian -> 2D).
% Add close figure at the last part.
% Show the total cell number in the menu function.
%  2019.07.01 
%  Modification on zero column error.
%  2019.08.07
%  Modification on showing pop up window. 
%  2019.08.09
%  The window for user indicates each cell images taken in multiple days.
%  2019.08.12
%  Modified some errors and wrote max projection image instead of z-stack
%  image because of run time. 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 6/11/2018.
%% Classify the cell in the first and second frame
clear
[Filename,PathName] = uigetfile('.tif','Select the subtracted registrated cropped image files to analysis','Multiselect','on');  % Cropped image folder
Class_folder='E:\BACKUP\대학원\연구실\MY_Projects\In_vivo_imaging\Cell_detection\TXN_detection_deep_learning\Classification_Blind\POE9\';
[fnm_cell,pth_cell]=uigetfile('.mat','Select the cell coordinate');
Cell_list_file=fullfile(pth_cell,fnm_cell);
load(Cell_list_file)
Cell_size=[71 71 71];
Window_size=370;
%% 
for i=1:size(Filename,2)
    sp=split(Filename{1,i},'.');
    spp=split(sp{1,1},'_');
    sp_name{2,i}=spp{2,1};
    mkdir([Class_folder sp_name{2,i}])
    mkdir([Class_folder sp_name{2,i} '\TXN'])
    mkdir([Class_folder sp_name{2,i} '\Non_TXN'])
    mkdir([Class_folder sp_name{2,i} '\NA'])
end
%%
dir_ts=dir([Class_folder sp_name{2,1} '\TXN']);
dir_no=dir([Class_folder sp_name{2,1} '\Non_TXN']);
dir_NA=dir([Class_folder sp_name{2,1} '\NA']);

dir_pre_cells=[dir_no(3:size(dir_no,1)); dir_ts(3:size(dir_ts,1)) ; dir_NA(3:size(dir_NA,1))];
fnd_result_file=dir(Class_folder);
if ~isempty(cell2mat(strfind({fnd_result_file.name},['NF_map_',sp_name{2,1},'.mat'])))
load([Class_folder,'NF_map_',sp_name{2,1},'.mat'])
else
    NF_map.list=[];
end
if ~size(dir_pre_cells,1)==0  % Find the date in the categorized folder
    i=1;
    while ~isempty(cell2mat(strfind({dir_pre_cells.name},[num2str(i) ,'.tif']))) && i<=size(Cells.list,1)
        i=i+1;
        start_here=i;
    end
else
    start_here=1;
end

%%
    clear im_exp
    load(Cell_list_file)
    NF_map.Cell_position=Cells.list;
for i=1:size(Filename,2)
    for k=1:Cells.zstack
    im{i}(:,:,k)=imread(fullfile(PathName,Filename{1,i}),k);
    end

    im_exp{i}=zeros(size(im{i},1)+2*floor(Cell_size(1,1)/2),size(im{i},2)+2*floor(Cell_size(1,2)/2),size(im{i},3)+2*floor(Cell_size(1,3)/2));
    im_exp{i}(floor(Cell_size(1,2)/2)+1:floor(Cell_size(1,2)/2)+size(im{i},1),floor(Cell_size(1,1)/2)+1:floor(Cell_size(1,1)/2)+size(im{i},2),...
           floor(Cell_size(1,3)/2)+1:floor(Cell_size(1,3)/2)+size(im{i},3))=im{i};
       end
    %%
     load(Cell_list_file)
    NF_map.Cell_position=Cells.list;
    n=8;
    for k=1:size(Cell_size,2)
        Cells.list(:,k)=Cells.list(:,k)+floor(Cell_size(1,k)/2);
    end
    j=start_here;

    handles.fig = figure(1);
set(gcf, 'Position',  [50, 30, Window_size*size(Filename,2), 950])


    while j<=size(Cells.list,1)    
    clear crop_im max_crop_im mont filt_mont;
clf('reset')

    for i=1:size(Filename,2)
crop_im{i}=im_exp{i}(round(Cells.list(j,2))-floor(Cell_size(1,2)/2):round(Cells.list(j,2))+floor(Cell_size(1,2)/2),...
               round(Cells.list(j,1))-floor(Cell_size(1,1)/2):round(Cells.list(j,1))+floor(Cell_size(1,1)/2),...
               round(Cells.list(j,3))-floor(Cell_size(1,3)/2):round(Cells.list(j,3))+floor(Cell_size(1,3)/2));

max_crop_im{i}=max(crop_im{i},[],3);

for jj=1:size(crop_im{i},3) % Filtering image
Bgimfilt=imgaussfilt(crop_im{i}(:,:,jj), 6);
subim=abs(crop_im{i}(:,:,jj)-Bgimfilt);
Filt_im{i}(:,:,jj)=imgaussfilt(subim,1.5);
end

for jj=1:size(crop_im{i},3) % Montage image making
              if mod(jj,n)==0
mont{i}(1+(floor(jj/n)-1)*Cell_size(1,1):(floor(jj/n))*Cell_size(1,1),1+(n-1)*Cell_size(1,2):(n)*Cell_size(1,2))=crop_im{i}(:,:,jj);
filt_mont{i}(1+(floor(jj/n)-1)*Cell_size(1,1):(floor(jj/n))*Cell_size(1,1),1+(n-1)*Cell_size(1,2):(n)*Cell_size(1,2))=Filt_im{i}(:,:,jj);
           else
mont{i}(1+floor(jj/n)*Cell_size(1,1):(floor(jj/n)+1)*Cell_size(1,1),1+(mod(jj,n)-1)*Cell_size(1,2):(mod(jj,n))*Cell_size(1,2))=crop_im{i}(:,:,jj);
filt_mont{i}(1+floor(jj/n)*Cell_size(1,1):(floor(jj/n)+1)*Cell_size(1,1),1+(mod(jj,n)-1)*Cell_size(1,2):(mod(jj,n))*Cell_size(1,2))=Filt_im{i}(:,:,jj);
           end
end


handles.axes1 = axes('Units','pixels','Position',[(Window_size+10)*(i-1)+50 50 Window_size 350]);   

imshow(filt_mont{i},[min(min(filt_mont{i})) 1.3*max(max(filt_mont{i}))])
colormap('gray')
axis equal tight off
hold on
handles.axes2 = axes('Units','pixels','Position',[(Window_size+10)*(i-1)+100 820 130 130]);
imagesc(max_crop_im{i})
axis equal tight off
colormap('gray')

handles.axes3 = axes('Units','pixels','Position',[(Window_size+10)*(i-1)+50 450 Window_size 350]);
imshow(mont{i},[min(min(mont{i})) 1.1*max(max(mont{i}))])
colormap('gray')
axis equal tight off
handles.axes4 = axes('Units','pixels','Position',[(Window_size+10)*(i-1)+300 820 130 130]);
imagesc(max(Filt_im{i},[],3))
axis equal tight off
colormap('gray')
hold all
    end

    i=1;
    clear sw
while i<=size(Filename,2)

%plot(NF_map.Cell_position(j,1),NF_map.Cell_position(j,2),'ro','markersize',50)
%sw=menu(['( ' num2str(j) '/' num2str(size(Cells.list,1)) ' )th cell. Is the cell has TXN site?'],'Non TS','TS','N/A Cell','Break');
sw(1,i)=input(['( ' num2str(j) '/' num2str(size(Cells.list,1)) ' )th cell of ' num2str(i) '/' num2str(size(Filename,2)) ' th image. Is the cell has TXN site?\n']);


if sw(1,i)==4 || sw(1,i)==6
    break
end
if sw(1,i)==5
    
    i=i-1;
else
    i=i+1;
end
end


if ~isempty(find(sw==6))
        j=j-1;    
        sw_del=NF_map.list(j,4:end);
for jj=1:size(sw_del,2)

    if sw_del(1,jj)==1
        delete([Class_folder,char(sp_name{2,jj}),'\Non_TXN\',num2str(j),'.tif'])
    end
    
    if sw_del(1,jj)==2
        delete([Class_folder,char(sp_name{2,jj}),'\TXN\',num2str(j),'.tif'])
    end
    
    if sw_del(1,jj)==3
        delete([Class_folder,char(sp_name{2,jj}),'\NA\',num2str(j),'.tif'])
    end
    
end



else  if ~isempty(find(sw==4))
    close(figure(1))
    close(figure(2))
    break
end



for k=1:size(Filename,2)
    

if sw(1,k)==1
    for jj=1%:size(crop_im{k},3)
        if jj==1
            %imwrite(uint16(crop_im{k}(:,:,jj)),[Class_folder,char(sp_name{2,k}),'\Non_TXN\',num2str(j),'.tif'],'Compression','none');
            imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\Non_TXN\',num2str(j),'.tif'],'Compression','none');
        else
   %imwrite(uint16(crop_im{k}(:,:,jj)),[Class_folder,char(sp_name{2,k}),'\Non_TXN\',num2str(j),'.tif'],'Writemode','Append','Compression','none');
   imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\Non_TXN\',num2str(j),'.tif'],'Compression','none');
        end
    end
end

if sw(1,k)==2
   for jj=1%:size(crop_im{k},3)
       if jj==1
           imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\TXN\',num2str(j),'.tif'],'Compression','none');
       else
   imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\TXN\',num2str(j),'.tif'],'Writemode','Append','Compression','none');
       end
   end
end

if sw(1,k)==3
   for jj=1%:size(crop_im{k},3)
       if jj==1
   imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\NA\',num2str(j),'.tif'],'Compression','none');        
       else
   imwrite(uint16(max(crop_im{k}(:,:,jj),[],3)),[Class_folder,char(sp_name{2,k}),'\NA\',num2str(j),'.tif'],'Writemode','Append','Compression','none');
       end
   end
end

end


NF_map.list(j,:)=[NF_map.Cell_position(j,1) NF_map.Cell_position(j,2) Cells.list(j,3)-floor(Cell_size(1,3)/2) sw];
j=j+1;
end
    end
  close(figure(1))
    close(figure(2))   

    
    %%
    clear NF_map
  load(Cell_list_file)
    NF_map.Cell_position=Cells.list;
    
    for f=1:size(Filename,2)
if j==size(Cells.list,1)+1
pth=[Class_folder char(sp_name{2,f})];
imds = imageDatastore(pth,'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
sw={'Non_TXN','TXN','NA'};

tmp=split(imds.Files,'.');
for ii=1:size(tmp,1)
spp_name{ii,1}=split(tmp{ii,1},'\');
end
for ii=1:size(spp_name{1,1},1)
    if ~isempty(findstr(char(spp_name{1,1}(ii,1)),'NA')) || ~isempty(findstr(char(spp_name{1,1}(ii,1)),'Non_TXN')) || ~isempty(findstr(char(spp_name{1,1}(ii,1)),'TXN'))
        ref=ii;
    end
end
clear tmp

NF=zeros(size(imds.Files,1),1);
for i=1:size(imds.Files,1)
    for jj=1:size(sw,2)
       if ~isempty(strfind(sw{1,jj},char(imds.Labels(i,1)))) && ~isempty(strfind(char(imds.Labels(i,1)),sw{1,jj}))
           g=str2num(cell2mat(spp_name{i,1}(ref+1,1)));
           if NF(g,1)==0
    NF(g,1)=jj;
           else
               error(['There are two' num2str(g) 'cell in different folder !!!!!!'])
           end
           end
    end   
end
NF_map.list(:,4)=NF;
NF_map.list(:,1:3)=NF_map.Cell_position;
end

NF_map.behavior=char(sp_name{2,f});
NF_map.zstack=Cells.zstack;
NF_map.filename=Cells.filename;

save([Class_folder,'NF_map_',char(sp_name{2,f}),'.mat'],'NF_map');
    end