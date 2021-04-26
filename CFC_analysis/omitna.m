function [omitna_data thr_Data]=omitna(data)

       g=1;
       thr_Data=data.Cell.Data;
       tmp=thr_Data(:,4:end);
       tmp(data.Cell.thres==0)=4;
       tmp(data.Cell.Data(:,4:end)==2)=2;
       thr_Data(:,4:end)=tmp;
%     if iscell(data.Cell.Data) || ~isempty(find(data.Cell.Data(:,4:end)~=1 & data.Cell.Data(:,4:end)~=2 & data.Cell.Data(:,4:end)~=3 & data.Cell.Data(:,4:end)~=0))
%   
%     else
    for j=1:size(data.Cell.Data,1) %Cell 
        if sum(thr_Data(j,:)==3 | thr_Data(j,:)==4)==0
    omitna_data(g,1:size(thr_Data,2))=thr_Data(j,:);
    g=g+1;
        end
    end
end