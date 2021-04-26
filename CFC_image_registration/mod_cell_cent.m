function mod_Cell_cent=mod_cell_cent(Cell_cent,dist)
%clear mod_list
%dist=20;
%I=imread(['H:\Image_data\OlympusTPM\20180607\','20180607_Arc_oe1_CFC_.tif'],163);
g=1;
mod_list=zeros(1,2);
%        [centers, radii]=Cell_segment_circle(I);
%        Cell_cent=centers
for i=1:size(Cell_cent,1)-1
    for j=i+1:size(Cell_cent,1)
        sum=0;
        for k=1:size(Cell_cent,2)
       sum=sum+(Cell_cent(i,k)-Cell_cent(j,k))^2 ;
        end
    if sum<dist^2
        mod_list(g,1:2)=[i j];
        g=g+1;
    end
        
    end
end
    clear cent 
    g=1;
for i=1:size(Cell_cent,1)
    if ~isempty(find(mod_list(:,1)==i))
%         mod_list
%         i
        row=find(mod_list(:,1)==i);
%         [(Cell_cent(mod_list(row,1),1)+Cell_cent(mod_list(row,2),1))/2,(Cell_cent(mod_list(row,1),2)+Cell_cent(mod_list(row,2),2))/2]
for k=1:size(Cell_cent,2)        
    if size(row,1)==1
cent(g,k)=(Cell_cent(mod_list(row,1),k)+Cell_cent(mod_list(row,2),k))/2;%,(Cell_cent(mod_list(row,1),2)+Cell_cent(mod_list(row,2),2))/2];
    end
end
g=g+1;
    else
    if isempty(find(mod_list(:,2)==i))
        for k=1:size(Cell_cent,2)
        cent(g,k)=Cell_cent(i,k);
        end
        g=g+1;
    end
    end
end
mod_Cell_cent=cent;

%% 
%%
% imagesc(I)
% colormap('gray')
% axis equal
% hold all
% plot(cent(:,1),cent(:,2),'ro','markersize',15,'linewidth',3)