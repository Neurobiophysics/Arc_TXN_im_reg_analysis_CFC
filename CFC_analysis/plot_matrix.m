function plot_matrix(cond_matrix,class,mousedat,Window_size,N,sw,rng)
handles.fig = figure(1);
set(gcf, 'Position',  [50, 30, Window_size(1,1),Window_size(1,2)])
x_wind=Window_size(1,1)/(size(mousedat,2)+1);
y_wind=Window_size(1,2)/(size(mousedat,1)+2.5);
shift=x_wind*0.2;
for i=1:size(mousedat,1)
    for j=1:N(i,1)
        handles.axes1 = axes('Units','pixels','Position',[(x_wind)*(j-1)+shift (y_wind+shift)*(i-1)+shift x_wind y_wind]);   
        switch sw
            case 1
        imshow(cond_matrix{class}{i,j},rng)
            case 2
        imagesc(cond_matrix{class}{i,j})
        end
        axis equal tight off
        colormap('copper')
        hold all
        for col=1:size(cond_matrix{class}{i,j},1)
            for row=1:size(cond_matrix{class}{i,j},2)
                text(col,row,num2str(100*cond_matrix{class}{i,j}(row,col),2),'HorizontalAlignment','center','Fontsize',x_wind*0.04,'color','w')
            end
        end
        title(mousedat{i,j}.Cell.Mouse)
    end
    handles.axes1 = axes('Units','pixels','Position',[(x_wind)*(j)+shift (y_wind+shift)*(i-1)+shift x_wind y_wind]);   
    ave_mat=mean(reshape(cell2mat(cond_matrix{class}(i,1:N(i,1))),size(cond_matrix{class}{i,j},1),size(cond_matrix{class}{i,j},2),N(i,1)),3,'omitnan');
    switch sw
            case 1
        imshow(ave_mat,rng)
            case 2
        imagesc(ave_mat)
    end
    axis equal tight off
        colormap('copper')
        hold all
        for col=1:size(cond_matrix{class}{i,j},1)
            for row=1:size(cond_matrix{class}{i,j},2)
                text(col,row,num2str(100*ave_mat(row,col),2),'HorizontalAlignment','center','Fontsize',x_wind*0.04,'color','w')
            end
        end
        title('Averaged')
end
end