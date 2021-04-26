function p=tree_graph(tree,path,group,color,ref)
% sw = 1 : /total cell, 2: /activated cell
sn=[5 4 5 5 6 6 6];
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);
for i=1:size(group,2)
tmp=cell2mat(tree(group(1,i),:));
t{i}=tmp([path],:);
sum(~isnan(t{i}),2)
errorbar([1:1:size(path,2)],mean(t{i},2,'omitnan'),std(t{i},0,2,'omitnan')./sqrt(sum(~isnan(t{i}),2)),'color',color(i,:),'linewidth',3)
hold all
end
xlim([0.5 size(path,2)+0.5])
ylim([0 0.8])
if size(group,2)==2
for i=1:size(t{1},1)
    [a p(i,1)]=ttest2(t{1}(i,:),t{2}(i,:));
    p(i,2)=ranksum(t{1}(i,:),t{2}(i,:));
    [a p(i,3)]=kstest2(t{1}(i,:),t{2}(i,:));
end
set(gca,'fontweight','bold','linewidth',1,...
    'FontName','arial rounded mt bold','FontSize',13,...
    'XTick',[1:1:size(path,2)],'XTickLabel',{'10','100','111','1111'})
if sum(p(:,ref)<0.05)
for i=find(p(:,ref)<0.05)
    if p(i,ref)<0.01
    text(i,0.9,'**','HorizontalAlignment', 'center','FontName','arial rounded mt bold','FontSize',13)
    else
    text(i,0.6,'*','HorizontalAlignment', 'center','FontName','arial rounded mt bold','FontSize',13)    
    end
end
end
end
ylabel('Reactivation probability','HorizontalAlignment', 'center','FontName','arial rounded mt bold','FontSize',13)
end