%%%  TXN analysis protocol : Subtraction & Max projection & Cell Segmentation 
%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% This code shows cell image and let user classify the TS cell and no TS
% cell.
% The analysis is proceed as following
% 1. Load the registrated images
% 2. Do subtraction in each z stack
% 3. Max projection
% 4. Cell Segment with Circle finder.

% INPUTS 

% The folder with images (3 stack, Reg, Green, Subtracted).
% 

% OUTPUTS


% MODIFICATION HISTORY : 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 6/11/2018.

%% Parameter setting
clear
[fnm,pth]=uigetfile('*.tif','Select the registrated subtracted image','Multiselect','on');
% [fnm_lip,pth_lip]=uigetfile('*.tif','Select the autofluorescence image','Multiselect','on');
channel=2;
timeline={'HC','Training','1st Retrieval','2nd Retrieval','3rd Retrieval'};%,'2nd Retrieval','3rd Retrieval','Remote'};
dist_thr=7;
N=2;
% target_RGB_Image='H:\Image_data\OlympusTPM\20180607\20180607_Arc_oe1_CFC_crop\t01_z01_cell_num0019.tif';
% target_Image='H:\Image_data\OlympusTPM\20180607\20180607_Arc_oe1_CFC_crop_sub\t01_z01_cell_num0019.tif';
%% Subtraction & Max Projection

for i=1:length(fnm)
    cro_im(:,:,i)=imread([pth char(fnm{1,i})],1);
end
im_log=cro_im==0;
im_int=1-max(im_log,[],3);
im_int_crop=im_int;
%while ~isempty(find(im_int_crop==0))
imagesc(im_int)
h = imrect(gca,[10 10 100 100]);
position=wait(h);
im_int_crop=imcrop(im_int,[round(position(1,1)) round(position(1,2)) round(position(1,3)) round(position(1,4))]);
%end
crop_pos=round(position);
%%
mkdir([pth,'crop'])
for i=1:length(fnm)
    
    
imginf=imfinfo([pth char(fnm{1,i})]);
zstack=size(imginf,1);    
sp_name=split(fnm{1,i},'_');

for j=1:zstack
    im(:,:,j)=imcrop(imread([pth char(fnm{1,i})],j),crop_pos);
    if j==1
    imwrite(uint16(im(:,:,j)),[pth '\crop\' sp_name{4,1},'_',sp_name{5,1},'.tif'],'Compression','none')
    else
    imwrite(uint16(im(:,:,j)),[pth '\crop\' sp_name{4,1},'_',sp_name{5,1},'.tif'],'Writemode','Append','Compression','none')
    end
end

max_sub(:,:,i)=max(im,[],3);
[det{i}, radii]=Cell_segment_circle(max_sub(:,:,i));
num_det(i,1)=size(det{i},1);
% if i==1
%     imwrite(max_sub(:,:,i),[pth 'max_sub.tif'],'Compression','none');
% else
% imwrite(max_sub(:,:,i),[pth 'max_sub.tif'],'Writemode','Append','Compression','none');
% end
end
[max_cell_numb ref]=max(num_det(:,1));
%%
zstack_circle=[];
h=waitbar(0,'Wait, please');
clear subt_crop
for i=1:zstack
     subt_crop(:,:,i)=imcrop(imread([pth char(fnm{1,ref})],i),crop_pos);
end

for i=1:size(subt_crop,2)
    reslice(:,:,i)=subt_crop(:,i,:);
    [centers, radii]=Cell_segment_circle_zslice(reslice(:,:,i));
    if ~isempty(centers)
        centers=mod_cell_cent(centers,3);
        col=zeros(size(centers,1),1)+i;
zstack_circle(size(zstack_circle,1)+1:size(zstack_circle,1)+size(centers,1),1:3)=[centers(:,2) col centers(:,1)];

    end
    waitbar((i)/size(subt_crop,2))
end
close(h)
%% Cell Segmentation in each image and match
for i=ref
    clear dist cell_list centers
    max_sub(:,:,i)=max(subt_crop(:,:,1:zstack),[],3);    
    g=1;
    h=waitbar(0,'Matching Cell position of Z and XY');
    for n=1:N
max_sub_{1,n}(:,:,i)=max(subt_crop(:,:,(n-1)*floor(zstack/N)+1:n*floor(zstack/N)),[],3);
%max_sub_2(:,:,i)=max(subt_crop(:,:,41:81),[],3);
    [centers{1,n}, radii]=Cell_segment_circle(max_sub_{1,n}(:,:,i));
    centers{1,n}=mod_cell_cent(centers{1,n},5);
%     [centers2, radii]=Cell_segment_circle(max_sub_2(:,:,i));
%     centers2=mod_cell_cent(centers2,3);

    for j=1:size(zstack_circle,1)
        for k=1:size(centers{1,n},1)
            dist(k,j)=distance_BH([centers{1,n}(k,2) centers{1,n}(k,1)],zstack_circle(j,1:2));
        end
    end
        for k=1:size(centers{1,n},1)
        [min_dist min_dist_arg]=min(dist(k,:));
        if min_dist<dist_thr && zstack_circle(min_dist_arg,3)<n*round(zstack/N) && zstack_circle(min_dist_arg,3)>round(zstack/N)*(n-1)
            cell_list(g,1:3)=[centers{1,n}(k,1) centers{1,n}(k,2) zstack_circle(min_dist_arg,3)];
            g=g+1;
        end
        end
        
        waitbar((n)/N)
    end
    close(h)
    
%     
%     for j=1:size(zstack_circle,1)
%         for k=1:size(centers2,1)
%             dist(k,j)=distance_BH([centers2(k,2) centers2(k,1)],zstack_circle(j,1:2));
%         end
%     end
%         for k=1:size(centers2,1)
%         [min_dist min_dist_arg]=min(dist(k,:));
%         if min_dist<dist_thr && zstack_circle(min_dist_arg,3)>40
%             cell_list(g,1:3)=[centers2(k,1) centers2(k,2) zstack_circle(min_dist_arg,3)];
%             g=g+1;
%         end
%         end
%     
    cell_list=mod_cell_cent(cell_list,7);
    %centers=Cell_segment2(max_sub(:,:,i),200,3,0.5);
    imagesc(max_sub(:,:,ref))
    colormap('gray')
    hold all
    plot3(cell_list(:,1),cell_list(:,2),cell_list(:,3),'ro')
   % plot(centers1(:,1),centers1(:,2),'bo')
% mod_Cell_cent=mod_cell_cent(centers,15);
%     Cell_cent{1,i}=mod_Cell_cent;
%  

sw=menu('OK?','OK','More');
  while sw==2
      
      figure(2)
      imagesc(max_sub(:,:,ref))
      colormap('gray')
      hold all
      plot(cell_list(:,1),cell_list(:,2),'ro')
      [x y]=ginput(1);
      z=input('Input the z centroid position\n');
      cell_list(size(cell_list,1)+1,1:3)=[x y z];
      close(figure(2))
      
      figure(2)
      imagesc(max_sub(:,:,ref))
      colormap('gray')
      hold all
      plot(cell_list(:,1),cell_list(:,2),'ro')
      sw=menu('OK?','OK','More');
  end
end
close(figure(2))
close(figure(1))
Cells.list=cell_list;
Cells.filename=char(fnm{1,ref});
Cells.max_image=max_sub;
Cells.zstack=zstack;
%Cells.timeline=timeline{1,ref};
Cells.crop=position;
save([pth 'Cell_list_' char(fnm{1,ref}) '.mat'],'Cells');
% %%
% % %%
% % [fnm,pth]=uigetfile('*.tif','Select the registrated subtracted image','Multiselect','on');
% 
% % cell_file=['H:\Image_data\OlympusTPM\20181008-20181012\OE9\Transformed_2\Cell_list_T_sub_lip_reg_20181008_OE9_HC_.tif'];
% Cell_size=[51 51 51];
% 
% clear map_lip map_filt im_exp crop_im Filt_im 
% % map=zeros(10*Cell_size(1,1),ceil(size(Cells.list,1)/10)*Cell_size(1,2),Cell_size(:,3));
% map_lip=zeros(10*Cell_size(1,1),ceil(size(Cells.list,1)/10)*Cell_size(1,2),Cell_size(:,3));
% %%
% for i=1:length(fnm)
%     sp_name=split(fnm{1,i},'_');
%     load([pth 'Cell_list_' char(fnm{1,ref}) '.mat'])
% for j=1:Cells.zstack
%     im(:,:,j)=imcrop(imread([pth char(fnm_lip{1,i})],j),round(Cells.crop));
% end
% 
%     im_exp=zeros(size(im,1)+2*floor(Cell_size(1,1)/2),size(im,2)+2*floor(Cell_size(1,2)/2),size(im,3)+2*floor(Cell_size(1,3)/2));
%     im_exp(floor(Cell_size(1,2)/2)+1:floor(Cell_size(1,2)/2)+size(im,1),floor(Cell_size(1,1)/2)+1:floor(Cell_size(1,1)/2)+size(im,2)...
%           ,floor(Cell_size(1,3)/2)+1:floor(Cell_size(1,3)/2)+size(im,3))=im;
%     for k=1:size(Cell_size,2)
%         Cells.list(:,k)=Cells.list(:,k)+floor(Cell_size(1,k)/2);
%     end
%     
% for j=1:size(Cells.list,1)    
%     clear crop_im max_crop_im;
% 
%     crop_im=im_exp(round(Cells.list(j,2))-floor(Cell_size(1,2)/2):round(Cells.list(j,2))+floor(Cell_size(1,2)/2),...
%                round(Cells.list(j,1))-floor(Cell_size(1,1)/2):round(Cells.list(j,1))+floor(Cell_size(1,1)/2),...
%                round(Cells.list(j,3))-floor(Cell_size(1,3)/2):round(Cells.list(j,3))+floor(Cell_size(1,3)/2));
%            
%            
%            if mod(j,10)==0
% map_lip(1+(10-1)*Cell_size(1,2):(10)*Cell_size(1,2),1+floor(j/10)*Cell_size(1,1):(floor(j/10)+1)*Cell_size(1,1),1:51)=crop_im;               
%            else
% map_lip(1+(mod(j,10)-1)*Cell_size(1,2):(mod(j,10))*Cell_size(1,2),1+floor(j/10)*Cell_size(1,1):(floor(j/10)+1)*Cell_size(1,1),1:51)=crop_im;
%            end
% %
% % for k=1:size(crop_im,3)
% % if k==1&&j==1
% %    imwrite(uint16(crop_im(:,:,k)),[pth,'\crop\lip_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Compression','none');
% % %   imwrite(uint16(Filt_im(:,:,k)),[pth,'\crop\','Filt_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Compression','none');
% % else
% %    imwrite(uint16(crop_im(:,:,k)),[pth,'\crop\lip_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none');
% % %   imwrite(uint16(Filt_im(:,:,k)),[pth,'\crop\','Filt_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none');
% % end
% % end
% %   imwrite(uint16(zeros(size(crop_im,1),size(crop_im,2))),[pth,'\crop\lip_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none');
% % %  imwrite(uint16(zeros(size(crop_im,1),size(crop_im,2))),[pth,'\crop\',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none');
% % 
% end
% for k=1:Cell_size(1,3)
%     imwrite(uint16(map_lip(:,:,k)),[pth,'\crop\lip_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none')
%     %imwrite(uint16(map_filt(:,:,k)),[pth,'\crop\','Filt_',char(sp_name(6,1)),'_',char(sp_name(7,1)),'.tif'],'Writemode','Append','Compression', 'none')
% end
% end
%%
% aviobj = VideoWriter([pth,char(fnm{1,2}),'_seg.avi']);
% open(aviobj);
% rod_z_cell_list=cell_list;
% rod_z_cell_list(:,3)=round(cell_list(:,3));
% for i=1:zstack
%     figure(1)
%     imagesc(subt_crop(:,:,i))
%     colormap('gray')
%     axis equal
%     hold all
%     [row col]=find(rod_z_cell_list(:,3)==i);
%     for j=1:size(row,1)
%     plot(rod_z_cell_list(row(j,1),1),rod_z_cell_list(row(j,1),2),'r.','markersize',15)
%     end
%     
%     F=figure(1);
% writeVideo(aviobj,getframe(F));
% end
% close(figure(1));
%  close(aviobj);
%  %%
%  aviobj = VideoWriter([pth,char(fnm{1,2}),'_seg_resl.avi']);
% open(aviobj);
% rod_z_cell_list=cell_list;
% rod_z_cell_list(:,1)=round(cell_list(:,1));
% 
% for i=1:size(subt_crop,2)
%     figure(1)
%     imagesc(reshape(subt_crop(:,i,:),size(subt_crop,1),size(subt_crop,3)))
%     colormap('gray')
%     axis equal
%     hold all
%     [row col]=find(rod_z_cell_list(:,1)==i);
%     for j=1:size(row,1)
%     plot(rod_z_cell_list(row(j,1),3),rod_z_cell_list(row(j,1),2),'r.','markersize',15)
%     end
%     
%     F=figure(1);
% writeVideo(aviobj,getframe(F));
% if ~mod(i,100)
%         close(figure(1))
%     end
% end
% close(figure(1));
%  close(aviobj);