function plot_venn(omitna_data,group,cond,soi,N,tick_coord)
xtick={'HC','CFC','Ret 1','Ret 2','Ret 3','Ret 4','Ret 5','Ret 6','Remote'};
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 200 200]);

c=[2 1 1;1 2 1;1 1 2;2 2 1;2 1 2;1 2 2; 2 2 2];
% Make NA cell omited data
if ~isempty(cond)
    gg=1;
for g=[group]
    for i=1:N(g,1)
con_omitna_data{g,i}=omitna_data{g,i}(find(omitna_data{g,i}(:,cond+3)==2),:);
for j=1:size(c,1)
ven_data{g}(j,i)=sum(con_omitna_data{g,i}(:,soi(1,1)+3)==c(j,1) &...
                     con_omitna_data{g,i}(:,soi(1,2)+3)==c(j,2) &...
                     con_omitna_data{g,i}(:,soi(1,3)+3)==c(j,3))...
                     /size(con_omitna_data{g,i},1);
end
    end
    subplot1=subplot(size(group,2),1,gg);

    M=mean(ven_data{g},2);
    sum(M)
    [a Venn_data{g}]=venn(M);
    for coor=1:7
        text(Venn_data{g}.ZoneCentroid(coor,1),Venn_data{g}.ZoneCentroid(coor,2),num2str(round(M(coor,1),3)*100),'HorizontalAlignment', 'center','Fontsize',10,'FontName','arial rounded mt bold')
    end
    gg=gg+1;
    axis equal tight off
    Venn_data{g}.Position
    
    for coor=1:3
        text(tick_coord(coor,1),tick_coord(coor,2),xtick{1,soi(1,coor)},'HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
    end
    set(subplot1,'DataAspectRatio',[1 1 1],'FontName','arial rounded mt bold',...
    'FontSize',15,'LineWidth',10)
end    
      
else % No condition
  gg=1;
for g=[group]
    for i=1:N(g,1)
con_omitna_data{g,i}=omitna_data{g,i};
for j=1:size(c,1)
ven_data{g}(j,i)=sum(con_omitna_data{g,i}(:,soi(1,1)+3)==c(j,1) &...
                     con_omitna_data{g,i}(:,soi(1,2)+3)==c(j,2) &...
                     con_omitna_data{g,i}(:,soi(1,3)+3)==c(j,3))...
                     /size(con_omitna_data{g,i},1);
end
    end
    subplot(size(group,2),1,gg)
    M=mean(ven_data{g},2);
    [a Venn_data{g}]=venn(M);

%     [a Venn_data{g}]=venn(M);
    for coor=1:7
        text(Venn_data{g}.ZoneCentroid(coor,1),Venn_data{g}.ZoneCentroid(coor,2),num2str(round(M(coor,1),2))*100,'HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
    end
    gg=gg+1;
end    
axis equal tight off
end
end