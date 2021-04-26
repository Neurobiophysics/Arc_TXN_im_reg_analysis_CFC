function plot_TXN(fracTXN,group,sw,color,N,xtick,y_lim) %sw for line
sess_number=[5 4 5 5 6 6 6];
G=[];
sh=0.2;
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
if size(group,2)==1
    G=meshgrid(1:sess_number(1,group(1,1)),1);
else
for i=1:size(group,2) % X axis, Grid
G=[G; meshgrid(1:sess_number(1,group(1,1)),1)-sh+sh*2/(size(group,2)-1)*(i-1)];
end
end
G=reshape(G,1,size(G,1)*size(G,2));
M=[]; S=[];
for i=group % data rearrange
M=[M; mean(fracTXN{i,1}(:,1:sess_number(1,i)),1,'omitnan')];
S=[S; std(fracTXN{i,1}(:,1:sess_number(1,i)),0,1,'omitnan')/sqrt(N(i,1))];
end
for i=1:size(group,2)    
    errorbar(G,100*M(i,:),100*S(i,:),...
        'LineWidth',2,'linestyle','none','color','k','Capsize',10)
end

b=bar(G,100*reshape(M,1,size(M,1)*size(M,2)),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
for i=1:size(group,2)    
for j=find(mod([1:1:size(M,1)*size(M,2)],size(group,2))==i*(i~=size(group,2)))
b.CData(j,:)= color(i,:);
end
end
hold all

set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:sess_number(1,group(1,1))],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
if sw==1
    for i=1:size(group,2)
    for j=1:size(fracTXN{group(1,i),1},1)
        plot(G(1,find(mod([1:size(G,2)],size(group,2))==i*(i~=size(group,2)))),100*fracTXN{group(1,i),1}(j,1:sess_number(1,group(1,1))),'color','k','marker','o','linewidth',1)
    end
    end
end
ylabel('Fraction of Arc-TXN neurons (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 sess_number(1,group(1,1))+0.5])
ylim([0 y_lim])
end