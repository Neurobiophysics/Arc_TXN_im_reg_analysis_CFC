%%%  TXN Analysis Protocol 1
%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% The analysis is proceed as following
% 1. Load the image
% 2. Calculate drift from lipofuscin tracking data.
% 3. Register and write image.

% INPUTS 

% 1. Images (2 channel, [R(1~n) G(1~n)].
% 2. Lipofuscin (auto-fluorescence) tracking data

% OUTPUTS

% MODIFICATION HISTORY : 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 6/11/2018.
clear
[fnm,pth]=uigetfile('*.tif','Select the raw image','Multiselect','on');
[fnmtr,pthtr]=uigetfile('*.mat','Select the tracking data','Multiselect','on');
%%
if ischar(fnm)
    fnm={fnm};
end

if ischar(fnmtr)
    fnmtr={fnmtr};
end
h=waitbar(0,'Drift calculation');

for i=1:length(fnm)
imginf=imfinfo([pth char(fnm{1,i})]);
numstack=size(imginf,1);  
ss=split(fnm{1,i},'.');
sp_name=split(ss{1,1},'_');
g=1;
clear lip_cred_tr lip_cred_tr_cov
for k=1:length(fnmtr)
    %if ~isempty(findstr(fnmtr{1,k},sp_name{3,1})) && ~isempty(findstr(sp_name{3,1},fnmtr{1,k}))
    if ~isempty(findstr(fnmtr{1,k},sp_name{3,1})) && ~isempty(findstr(sp_name{3,1},fnmtr{1,k}))
       lip_tr=importdata([pthtr fnmtr{1,k}]);
              lip_cred_tr{1}=zeros(81,1);
       lip_cred_tr{2}=zeros(81,1);
       for ptl=1:max(lip_tr.trackingData(:,1))
           

       
           if size(find(lip_tr.trackingData(:,1)==ptl),1)>3
               clear dif row
               lip_cred_tr{1}(lip_tr.trackingData(find(lip_tr.trackingData(:,1)==ptl),2),g)=[NaN ; diff(lip_tr.trackingData(find(lip_tr.trackingData(:,1)==ptl),3))];
               lip_cred_tr{2}(lip_tr.trackingData(find(lip_tr.trackingData(:,1)==ptl),2),g)=[NaN ; diff(lip_tr.trackingData(find(lip_tr.trackingData(:,1)==ptl),4))];
                g=g+1;
           end
       end
       lip_cred_tr_cov=lip_cred_tr;
       lip_cred_tr_cov{1}(lip_cred_tr{1}==0)=NaN;
       lip_cred_tr_cov{2}(lip_cred_tr{2}==0)=NaN;
       
       lip_cred_tr_cov{1}(isnan(lip_cred_tr{1}))=0;
       lip_cred_tr_cov{2}(isnan(lip_cred_tr{2}))=0;
       drift{i,1}(1:numstack/2,:)=round(cumsum(mean(lip_cred_tr_cov{1}(1:numstack/2,:),2,'omitnan'),'omitnan'));
       drift{i,2}(1:numstack/2,:)=round(cumsum(mean(lip_cred_tr_cov{2}(1:numstack/2,:),2,'omitnan'),'omitnan'));
    end
end
waitbar((i)/length(fnm))
end
close(h)
%calculate drift
%%
h=waitbar(0,'Registration');

for i=1:length(fnm)
    clear im2 subtraction
    imginf=imfinfo([pth char(fnm{1,i})]);
numstack=size(imginf,1);  

im2{1}=zeros(imginf(1).Height+abs(min(drift{i,2}(:,1)))*(1-heaviside(min(drift{i,2}(:,1))))+abs(max(drift{i,2}(:,1))),imginf(1).Width+abs(min(drift{i,1}(:,1)))*(1-heaviside(min(drift{i,1}(:,1))))+abs(max(drift{i,1}(:,1))),numstack/2);
im2{2}=zeros(imginf(1).Height+abs(min(drift{i,2}(:,1)))*(1-heaviside(min(drift{i,2}(:,1))))+abs(max(drift{i,2}(:,1))),imginf(1).Width+abs(min(drift{i,1}(:,1)))*(1-heaviside(min(drift{i,1}(:,1))))+abs(max(drift{i,1}(:,1))),numstack/2);
for j=1:numstack/2   

im=zeros(imginf(1).Height+abs(min(drift{i,2}(:,1)))*(1-heaviside(min(drift{i,2}(:,1))))+abs(max(drift{i,2}(:,1))),imginf(1).Width+abs(min(drift{i,1}(:,1)))*(1-heaviside(min(drift{i,1}(:,1))))+abs(max(drift{i,1}(:,1))),1);
im(abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+1:abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+imginf(1).Height,...
   abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+1:abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+imginf(1).Width,1)=imread([pth char(fnm{1,i})],j);

im2{1}(abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+1:abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+imginf(1).Height,...
   abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+1:abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+imginf(1).Width,j)=imread([pth char(fnm{1,i})],j);
im2{2}(abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+1:abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+imginf(1).Height,...
   abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+1:abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+imginf(1).Width,j)=imread([pth char(fnm{1,i})],numstack/2+j);


   
%     imwrite(uint16(imcrop(im,cro_pos)),[pth 'lip_reg_' char(fnm{1,i})],'Writemode','Append','Compression','none');
%imwrite(uint16(mask(:,:,j)),[pth 'mask_' char(fnm{1,1})],'Writemode','Append','Compression','none');

end   

cro_pos=[abs(max(drift{i,1}(:,1)))-drift{i,2}(1,1)+1 abs(max(drift{i,2}(:,1)))-drift{i,1}(1,1)+1 imginf(1).Height-1 imginf(1).Width-1];
% for z=1:numstack/2
% subtraction(:,:,z)=im2{1}(:,:,z);
% subtraction(:,:,z+numstack/2)=im2{2}(:,:,z);
% end
subtraction=subtraction_image_ftn_cell(im2);


for j=1:numstack/2
%     im2(abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+1:abs(max(drift{i,2}(:,1)))-drift{i,2}(j,1)+imginf(1).Height,...
%    abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+1:abs(max(drift{i,1}(:,1)))-drift{i,1}(j,1)+imginf(1).Width,2)=imread([pth char(fnm{1,i})],numstack/2+j);
%      imwrite(uint16(imcrop(im2(:,:,2),cro_pos)),[pth 'lip_reg_' char(fnm{1,i})],'Writemode','Append','Compression','none');
imwrite(uint16(imcrop(im2{1}(:,:,j),cro_pos)),[pth 'Lip_' char(fnm{1,i})],'Writemode','Append','Compression','none');
% imwrite(uint16(imcrop(im2{2}(:,:,j),cro_pos)),[pth 'reg_' char(fnm{1,i})],'Writemode','Append','Compression','none');
imwrite(uint16(imcrop(subtraction(:,:,j),cro_pos)),[pth 'sub_' char(fnm{1,i})],'Writemode','Append','Compression','none');
end
  

waitbar((i)/length(fnm))
end
close(h)