function chan_mat=chance_matrix(omitna_data,N)
sess_number=[5 4 5 5 6 6 6];

    for g=1:size(omitna_data,1) %group
        for i=1:N(g,1) %mouse
            for j=1:sess_number(g) %overlap case
                for jj=1:sess_number(g) 
                    if g==7 && i==3 && (j==6 || jj==6)
                        for k=1:3
                      chan_mat{k}{g,i}(j,jj)=NaN;
                        end
                    else
                        
                    overlap_matrix(j,jj)=sum(omitna_data{g,i}(:,j+3)==2) * sum(omitna_data{g,i}(:,jj+3)==2);
                    chan_mat{1}{g,i}(j,jj)=overlap_matrix(j,jj)/size(omitna_data{g,i},1)^2; % overlap
                    chan_mat{2}{g,i}(j,jj)=sum(omitna_data{g,i}(:,jj+3)==2)/size(omitna_data{g,i},1); % cond chance
                    chan_mat{3}{g,i}(j,jj)=sum(omitna_data{g,i}(:,j+3)==1 & omitna_data{g,i}(:,jj+3)==2)/sum(omitna_data{g,i}(:,j+3)==1); % cond negative
                    end
            if j==jj && isnan(chan_mat{3}{g,i}(j,jj))
                    chan_mat{3}{g,i}(j,jj)=0;
            end
               end
            end
        end
    end
    
end