function [cum_mat cum_mat_norm cum_mat_ch cum_mat_ch_norm]=cumulative_frac(omitna_data,N,class)
sess_number=[5 4 5 5 6 6 6];
    for g=1:size(omitna_data,1) %group
        for i=1:N(g,1) %mouse
        session_to_anal=sess_number(1,g);
   
for ref=2:session_to_anal %starting session
    row=zeros(size(omitna_data{g,i},1),1)+1; %
    p=1;
    
for j=ref:session_to_anal %ex) CFC~Ret1, CFC~Ret2, ... Ret4
row=omitna_data{g,i}(:,j+3)==class(1,j-1) & row;
cum_mat{g,ref-1}(i,j-ref+1)=sum(row)/size(omitna_data{g,i},1);
p=p*sum(omitna_data{g,i}(:,j+3)==class(1,j-1))/size(omitna_data{g,i},1);
cum_mat_ch{g,ref-1}(i,j-ref+1)=p;
end
end
        end
     for i=1:session_to_anal-2
cum_mat_norm{g,i}=cum_mat{g,i}./cum_mat{g,i}(:,1);
cum_mat_ch_norm{g,i}=cum_mat_ch{g,i}./cum_mat_ch{g,i}(:,1);
     end
    end
end