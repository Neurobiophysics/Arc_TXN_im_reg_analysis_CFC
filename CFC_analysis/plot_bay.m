function plot_bay(Bay_prob,group,sw,color,N,xtick,y_lim) %sw for line
G=[];
sh=0.2;
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 400 400]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for i=1:2 % X axis, Grid
G=[G; meshgrid(1:1,1)-sh+sh*2/(2-1)*(i-1)];
end
G=reshape(G,1,size(G,1)*size(G,2));
M=[]; S=[];

%datum=nan(size(Bay_prob{1},2),2);
datum=[Bay_prob{group(1,1)}(group(1,2),:)' Bay_prob{group(2,1)}(group(2,2),:)'];

    errorbar(G,100*mean(datum,1,'omitnan'),100*std(datum,0,1,'omitnan')./sqrt(N([group(1,2) group(2,2)],1)'),...
        'LineWidth',2,'linestyle','none','color','k','Capsize',10)


b=bar(G,100*mean(datum,1,'omitnan'),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
b.CData(1,:)= color(1,:);
b.CData(2,:)= color(2,:);

hold all

if group(1,2)==group(2,2)
    [h p_value(1,1)]=ttest(datum(:,1),datum(:,2));
else
    [h p_value(1,1)]=ttest2(datum(:,1),datum(:,2));
end
    p_value(1,2)=ranksum(datum(:,1),datum(:,2));
    [h p_value(1,3)]=kstest2(datum(:,1),datum(:,2));


set(gca,'FontSize',8,'LineWidth',1,'XTick',G,'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
if sw==1
    for i=1:size(group,2)
    for j=1:size(fracTXN{group(1,i),1},1)
        plot(G(1,find(mod([1:size(G,2)],size(group,2))==i*(i~=size(group,2)))),fracTXN{group(1,i),1}(j,1:sess_number(1,group(1,1))),'color',color(i,:),'marker','.')
    end
    end
end
ylabel('Bayesian probability (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 1+0.5])
ylim([0 y_lim])

for ref=1:3
[r c]=find(p_value(:,ref)<0.01);
[rr cc]=find(p_value(:,ref)<0.05 & p_value(:,ref)>0.01);

for i=r'
    line([i-0.2 i+0.2],[y_lim*(0.85+0.1*(ref-1)) y_lim*(0.85+0.1*(ref-1))],'color','k','linewidth',1.5);
    text(i,y_lim*(0.87+0.1*(ref-1)),'**','HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
end
for i=rr'
    line([i-0.2 i+0.2],[y_lim*(0.85+0.1*(ref-1)) y_lim*(0.85+0.1*(ref-1))],'color','k','linewidth',1.5)
    text(i,y_lim*(0.87+0.1*(ref-1)),'*','HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
end
end
end