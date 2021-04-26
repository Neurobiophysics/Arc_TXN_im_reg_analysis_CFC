% Correction code
% MODIFICATION HISTORY : 
%  2019.01.24.
%  Change the string finding condition while finding the mouse number in
%  excel file.
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 2019.01.30.

%% 
pth=uigetdir('select the classfied folder');
imds = imageDatastore(pth,'IncludeSubfolders',true,'LabelSource',...
    'foldernames');
sw={'Non_TXN','TXN','NA'};
%%
tmp=split(imds.Files,'.');
for i=1:size(tmp,1)
sp_name{i,1}=split(tmp{i,1},'\');
end
for i=1:size(sp_name{1,1},1)
    if ~isempty(findstr(char(sp_name{1,1}(i,1)),'NA')) || ~isempty(findstr(char(sp_name{1,1}(i,1)),'Non_TXN')) || ~isempty(findstr(char(sp_name{1,1}(i,1)),'TXN'))
        ref=i;
    end
end
clear tmp
%%
clear NF
NF=zeros(size(imds.Files,1),1);
for i=1:size(imds.Files,1)
    for j=1:size(sw,2)
       if ~isempty(strfind(sw{1,j},char(imds.Labels(i,1)))) && ~isempty(strfind(char(imds.Labels(i,1)),sw{1,j}))
           g=str2num(cell2mat(sp_name{i,1}(ref+1,1)));
           if NF(g,1)==0
    NF(g,1)=j;
           else
               error(['There are two' num2str(g) 'cell in different folder !!!!!!'])
           end
           end
    end
    
end