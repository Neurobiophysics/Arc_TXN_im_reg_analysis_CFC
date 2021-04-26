function cond_matrix=cond_matrix(omitna_data,N)
sess_number=[5 4 5 5 6 6 6];

    for g=1:size(omitna_data,1) %group
        for i=1:N(g,1) %mouse
            for j=1:sess_number(g) %overlap case
                for jj=1:sess_number(g) 
                    overlap_matrix(j,jj)=sum(omitna_data{g,i}(:,j+3)==2 & omitna_data{g,i}(:,jj+3)==2);
                    if g==7 && i==3 && (j==6 || jj==6)
                        for k=1:6
                      cond_matrix{k}{g,i}(j,jj)=NaN;
                        end
                    else
                    cond_matrix{1}{g,i}(j,jj)=overlap_matrix(j,jj)/size(omitna_data{g,i},1); % overlap
                    cond_matrix{2}{g,i}(j,jj)=overlap_matrix(j,jj)/sum(omitna_data{g,i}(:,j+3)==2 | omitna_data{g,i}(:,jj+3)==2); % similarity, 'Jaccard'
                    cond_matrix{3}{g,i}(j,jj)=overlap_matrix(j,jj)/sum(omitna_data{g,i}(:,j+3)==2); % cond_prob
                    cond_matrix{4}{g,i}(j,jj)=(overlap_matrix(j,jj)-sum(omitna_data{g,i}(:,j+3)==2)*sum(omitna_data{g,i}(:,jj+3)==2)/size(omitna_data{g,i},1)^2)...
                                       /(min(sum(omitna_data{g,i}(:,jj+3)==2),sum(omitna_data{g,i}(:,j+3)==2))-sum(omitna_data{g,i}(:,j+3)==2)*sum(omitna_data{g,i}(:,jj+3)==2)/size(omitna_data{g,i},1)^2);
                                       % similarity score 'Guzowski'
                     cond_matrix{5}{g,i}(j,jj)=acos(overlap_matrix(j,jj)/sqrt(sum(omitna_data{g,i}(:,j+3)==2)*sum(omitna_data{g,i}(:,jj+3)==2)))*180/pi; %Angle
                     cond_matrix{6}{g,i}(j,jj)=sum((omitna_data{g,i}(:,j+3)==2) ~= (omitna_data{g,i}(:,jj+3)==2))/size(omitna_data{g,i},1); %distance
                if j==jj && isnan(cond_matrix{3}{g,i}(j,jj))
                    cond_matrix{3}{g,i}(j,jj)=1;
                end
                    end
                end
            end
            
            
        end
    end
    
end