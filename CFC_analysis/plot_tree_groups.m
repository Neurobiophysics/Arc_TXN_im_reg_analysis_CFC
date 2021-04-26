function plot_tree_groups(tree,groups,interest,xtck)
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],'Renderer','painters','position',[100 100 300 300]);

cmap=[0.2 0.8 0.8;0.8 0.2 0.8];
i=1;

for g=groups
    tmp=cell2mat(tree(g,:));
    datum{g}=tmp(interest,:)';
    M(g,:)=mean(datum{g},1,'omitnan');
    S(g,:)=std(datum{g},0,1,'omitnan')./sqrt(sum(~isnan(datum{g}),1));
    errorbar([1:size(datum{g},2)],M(g,:),S(g,:),...
        'LineWidth',2,'color',cmap(i,:),'Capsize',10,'marker','+','markersize',10)
   hold all
   i=i+1;
end

for i=1:size(datum{g},2)
    [a p(i,1)]=ttest2(datum{groups(1)}(:,i),datum{groups(2)}(:,i));
    [a p(i,2)]=kstest2(datum{groups(1)}(:,i),datum{groups(2)}(:,i));
    p(i,3)=ranksum(datum{groups(1)}(:,i),datum{groups(2)}(:,i));
    p
   ref=1;
   if p(i,ref)<0.05
    star='*';
    if p(i,ref)<0.01
        star='**';
        if p(i,ref)<0.001
            star='***';
        end
    end
    text(i,max(M(:,i)+S(:,i))+0.1,star,'FontSize',13,'FontName','arial rounded mt bold',...
        'HorizontalAlignment', 'center')
   end
end
xlim([0.5 size(datum{g},2)+0.5])
ylabel('Reactivation probability','FontName','arial rounded mt bold','FontSize',13)
xlabel('Prior activation history','FontName','arial rounded mt bold','FontSize',13)
set(gca,'XTick',[1:size(datum{g},2)],'XTickLabel',xtick...
    ,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
end