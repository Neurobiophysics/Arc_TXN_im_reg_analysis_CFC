function plot_matrix_p_two_group(cond_matrix,group,class,p_mat,p_value,N,rng,p_class)
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[50, 30, 1000 600]);
switch group(1,1)
    case {1 , 3}
ticks={'HC','CFC','Ret 1','Ret 2','Ret 3'};
    case 2
ticks={'HC','CFC','Ret 1','Ctx B'};
    case 4
ticks={'HC','CFC','Ret 1','Ret 2','Ctx B'};
    case {5 , 6 , 7}
ticks={'HC','CFC','Ret 1','Ret 2','Ret 3','Ret 4'};
end
b=subplot(1,3,1);
ave_mat=mean(reshape(cell2mat(cond_matrix{class}(group(1,1),1:N(group(1,1),1))),size(cond_matrix{class}{group(1,1),1},1),size(cond_matrix{class}{group(1,1),1},2),N(group(1,1),1)),3,'omitnan');
        imagesc(ave_mat,rng)
        axis equal tight
        colormap(b,'copper')
        colorbar
        hold all
        set(gca,'XTick',[1:1:size(cond_matrix{class}{group(1,1),1},1)],'XTickLabel',ticks,'YTick',[1:1:size(cond_matrix{class}{group(1,1),1},1)],'YTickLabel',ticks,'xaxislocation','top','Fontsize',8)
         for col=1:size(cond_matrix{class}{group(1,1),1},1)
            for row=1:size(cond_matrix{class}{group(1,1),1},2)
                text(col,row,num2str(ave_mat(row,col),2),'HorizontalAlignment','center','Fontsize',8)
            end
        end
        title(['Group' num2str(group(1,1)) ' averaged'])
       
ave_mat_ch=mean(reshape(cell2mat(cond_matrix{class}(group(1,2),1:N(group(1,2),1))),size(cond_matrix{class}{group(1,2),1},1),size(cond_matrix{class}{group(1,2),1},2),N(group(1,2),1)),3,'omitnan');        
      b= subplot(1,3,2);
        imagesc(ave_mat_ch,rng)
        axis equal tight
        colormap(b,'copper')
        colorbar
        hold all
         for col=1:size(ave_mat_ch,1)
            for row=1:size(ave_mat_ch,2)
                text(col,row,num2str(ave_mat_ch(row,col),2),'HorizontalAlignment','center','Fontsize',8)
            end
        end
        title(['Group' num2str(group(1,2)) ' averaged'])
        set(gca,'XTick',[1:1:size(cond_matrix{class}{group(1,2),1},1)],'XTickLabel',ticks,'YTick',[1:1:size(cond_matrix{class}{group(1,2),1},1)],'YTickLabel',ticks,'xaxislocation','top','Fontsize',8)
       
        b= subplot(1,3,3);
        imagesc(p_value{p_class},[0 1])
        axis equal tight
        colormap(b,'copper')
        colorbar
        hold all
        set(gca,'XTick',[1:1:size(cond_matrix{class}{group(1,1),1},1)],'XTickLabel',ticks,'YTick',[1:1:size(cond_matrix{class}{group(1,1),1},1)],'YTickLabel',ticks,'xaxislocation','top','Fontsize',8)
         for col=1:size(p_value{p_class},1)
            for row=1:size(p_value{p_class},2)
                text(col,row,num2str(p_value{p_class}(row,col),2),'HorizontalAlignment','center','Fontsize',8)
                for k=1:3 
                     if p_mat{k}(col,row)>0
                color=zeros(1,3);
                color(1,k)=1;
                box_line(row,col,color,k*0.1) 
                hold all
                     end
                end
            end
        end
        title('P-value')
        
% for i=1:3
%     ax=subplot(1,5,i+2);
%     imagesc(p_mat{1,i})
%     colormap(ax,pink)
%     axis equal tight
%     set(gca,'XTick',[1:1:size(cond_matrix{class}{group,1},1)],'XTickLabel',ticks,'YTick',[1:1:size(cond_matrix{class}{group,1},1)],'YTickLabel',ticks,'xaxislocation','top')
% end
end
