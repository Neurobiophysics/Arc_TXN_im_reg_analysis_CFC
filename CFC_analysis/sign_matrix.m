function [p_mat p compare]=sign_matrix(cond_mat,group,class,N)
if sum(size(cond_mat{1,class}(group(1,1),1)))~=sum(size(cond_mat{1,class}(group(1,2),1)))
    error('check the group size!')
end
sess=[size(cond_mat{1,class}{group(1,1),1},1) size(cond_mat{1,class}{group(1,2),1},1)];
res{1,1}=reshape(cell2mat(cond_mat{1,class}(group(1,1),:)),sess(1,1),sess(1,1),N(group(1,1),1));
res{2,1}=reshape(cell2mat(cond_mat{1,class}(group(1,2),:)),sess(1,2),sess(1,2),N(group(1,2),1));
sess2=min(sess);
for i=1:sess2(1,1) % interest row
   for j=1:sess2(1,1) % interest col       
       compare{i,j}=nan(max(N(group(1,1),1),N(group(1,2),1)),2);
       compare{i,j}(1:N(group(1,1),1),1)=squeeze(res{1,1}(i,j,:));
       compare{i,j}(1:N(group(1,2),1),2)=squeeze(res{2,1}(i,j,:));
       [h p{1,1}(i,j)]=ttest2(compare{i,j}(:,1),compare{i,j}(:,2)); % p{1}= ttest
       p{2,1}(i,j)=ranksum(compare{i,j}(:,1),compare{i,j}(:,2)); % p{2}= MW test
       [h p{3,1}(i,j)]=kstest2(compare{i,j}(:,1),compare{i,j}(:,2)); % p{3}= Ks test;
end
end
for k=1:size(p,1)
    p_mat{k}=zeros(size(p{k,1},1),size(p{k,1},2));
    p_mat{k}(p{k,1}<0.05)=0.5;
    p_mat{k}(p{k,1}<0.01)=1;
end
end