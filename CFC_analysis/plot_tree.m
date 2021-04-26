function p=plot_tree(omitna_data,N,sw,group)
% sw = 1 : /total cell, 2: /activated cell
sn=[4 4 5 5 6 6 6];
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 580 470]);
for i=1:size(omitna_data,1)
    for j=1:N(i,1)
    p{i,j}=[];
    for s=1:sn(1,i)-1 %sessions
    cod=dec2bin([0:1:2^s-1]);
    for c=1:size(cod,1) %codes
    cd=split(cod(c,:),'');
    switch sw
        case 1
    p{i,j}(size(p{i,j},1)+1,1)=sum(sum((omitna_data{i,j}(:,5:s+4)==2)==str2num(char(cd(2:end-1,:)))',2)==s)/...
                               size(omitna_data{i,j},1);
        case 2
            if s==1
    p{i,j}(size(p{i,j},1)+1,1)=sum(sum((omitna_data{i,j}(:,5:s+4)==2)==str2num(char(cd(2:end-1,:)))',2)==s)/...
                               size(omitna_data{i,j},1);
            else
                if sum(sum((omitna_data{i,j}(:,5:s+3)==2)==str2num(char(cd(2:end-2,:)))',2)==s-1)==0
                p{i,j}(size(p{i,j},1)+1,1)=NaN;
                else
    p{i,j}(size(p{i,j},1)+1,1)=sum(sum((omitna_data{i,j}(:,5:s+4)==2)==str2num(char(cd(2:end-1,:)))',2)==s)/...
                               sum(sum((omitna_data{i,j}(:,5:s+3)==2)==str2num(char(cd(2:end-2,:)))',2)==s-1);  
                end
            end
    end
    end
    end
    end
mean_p{i,1}=mean(cell2mat(p(i,1:N(i,1))),2,'omitnan');

    

end
tree_plot(mean_p{group,1},1)
end
function tree_plot(p,scale)
    cmap = jet(100);
    ps=p*scale;
    ps(ps>0.98)=0.98;
    
    s=find([2 6 14 30 62]==size(p,1));
    y=fliplr([0.1:0.8/s:0.9]);
    for i=1:s+1
        x{i}=[1/2^i:2/2^i:(2^i-1)/2^i];
    end
    g=1;
    s_name={'CFC','Ret 1','Ret 2','Ret 3','Ret 4'};
    for i=1:size(y,2)-1
      text(0.3-i*0.1,y(1,i),s_name{1,i},'color','w'...
           ,'FontName','arial rounded mt bold','Fontsize',14,'HorizontalAlignment', 'center')
        hold all
        for j=1:2^i
        c_value=round(round(ps(g,1),2)*100)+1; 
        if c_value>100
        c_value=100; end
        plot([x{i}(1,round(j/2)) x{i+1}(1,j)],[y(1,i) y(1,i+1)],'color',cmap(c_value,:),'linewidth',5,'marker','.','markersize',15)
       
        text(mean([0.2*x{i}(1,round(j/2)) 1.8*x{i+1}(1,j)]),mean([y(1,i) y(1,i+1)]),num2str(round(p(g,1),2)*100),'color','k'...
           ,'FontName','arial rounded mt bold','Fontsize',6,'HorizontalAlignment', 'center')
        
        g=g+1;
    end
    end
    on_off_tick={'0','1'};
    for i=1:size(y,2)-1
        for j=1:2^i
    
    text(x{i+1}(1,j),y(1,i+1),on_off_tick{mod(j+1,2)+1},'color','k'...
           ,'FontName','arial rounded mt bold','Fontsize',6,'HorizontalAlignment', 'center')
    
    end
    end
       colormap('jet')
    colorbar('Ticks',[0:0.2:1],'TickLabels',{'0 %','20 %','40 %','60 %','80 %','100 %'},'FontName','arial rounded mt bold','Fontsize',8)
    axis off
end