function Bay_prob=bayesian_prob(omitna_data,N)
ref=[5 4 5 5 6 6 6];
stt=2;
Bay_prob{1}=nan(size(omitna_data,1),size(omitna_data,2));
Bay_prob{2}=nan(size(omitna_data,1),size(omitna_data,2));
for i=1:size(omitna_data,1)     % Group
    for k=1:N(i,1) % Mouse 
        cond_data{i,k,1}=omitna_data{i,k}(find(omitna_data{i,k}(:,ref(1,i)+3)==2),stt+3:ref(1,i)+2)==2;
        cond_data{i,k,2}=omitna_data{i,k}(find(omitna_data{i,k}(:,ref(1,i)+3)==1),stt+3:ref(1,i)+2)==2;
        cond_data_prob{i,k,1}=sum(cond_data{i,k,1},2)/size(cond_data{i,k,1},2);
        cond_data_prob{i,k,2}=sum(cond_data{i,k,2},2)/size(cond_data{i,k,2},2);
        Bay_prob{1}(i,k)=mean(cond_data_prob{i,k,1});
        Bay_prob{2}(i,k)=mean(cond_data_prob{i,k,2});
    end
    
end
