function [fracTXN fracTXN_norm]=fraction_TXN(omitna_data,thr_Data,sw)

for i=1:size(omitna_data,1)     % Group
    for k=1:size(omitna_data,2) % Mouse 
      for j=4:size(omitna_data{i,k},2)
       if sw==1
       fracTXN{i,1}(k,j-3)=sum(thr_Data{i,k}(:,j)==2 & thr_Data{i,k}(:,j)~=4 & thr_Data{i,k}(:,j)~=3)/sum(thr_Data{i,k}(:,j)~=4 & thr_Data{i,k}(:,j)~=3); %각 날짜에서 OK;
       else
       fracTXN{i,1}(k,j-3)=sum(omitna_data{i,k}(:,j)==2 & omitna_data{i,k}(:,j)~=4 & omitna_data{i,k}(:,j)~=3)/sum(omitna_data{i,k}(:,j)~=4 & omitna_data{i,k}(:,j)~=3);
      end
      end
     
    end
 %   fracTXN{i,1}(fracTXN{i,1}==0)=NaN;
     fracTXN_norm{i,1}=fracTXN{i,1}./fracTXN{i,1}(:,2);
end
end
