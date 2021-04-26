function plot_ctxB(fracTXN,group,soi,sw,color,N,xtick,y_lim) %sw for line
sess_number=[5 4 5 5 6 6 6];
G=[];
sh=0.2;
figure2 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);

% Create axes
axes1 = axes('Parent',figure2);
hold(axes1,'on');
if size(group,2)==1
    G=meshgrid(1:sess_number(1,group(1,1)),1);
else
for i=1:size(group,2) % X axis, Grid
G=[G; meshgrid(1:size(soi,2),1)-sh+sh*2/(size(group,2)-1)*(i-1)];
end
end
G=reshape(G,1,size(G,1)*size(G,2));
datum=zeros(max([size(fracTXN{group(1,1),1},1) size(fracTXN{group(2,1),1},1)...
                 size(fracTXN{group(1,2),1},1) size(fracTXN{group(2,2),1},1)]),4);
datum(datum==0)=NaN;
datum(1:size(fracTXN{group(1,1),1},1),1)=fracTXN{group(1,1),1}(:,soi(1,1));
datum(1:size(fracTXN{group(1,2),1},1),2)=fracTXN{group(1,2),1}(:,soi(1,2));
datum(1:size(fracTXN{group(2,1),1},1),3)=fracTXN{group(2,1),1}(:,soi(2,1));
datum(1:size(fracTXN{group(2,2),1},1),4)=fracTXN{group(2,2),1}(:,soi(2,2));
M=mean(datum,1,'omitnan');
S=std(datum,0,1,'omitnan')./sqrt(N([group(1,1:2) group(2,1:2)],1)');
errorbar(G,100*reshape(M,1,size(M,1)*size(M,2)),100*reshape(S,1,size(S,1)*size(S,2))...
                             ,'LineWidth',2,'linestyle','none','color','k','Capsize',10)

b=bar(G,100*reshape(M,1,size(M,1)*size(M,2)),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
for j=1:4
b.CData(j,:)= color(j,:);
end
hold all
set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:sess_number(1,group(1,1))],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
if sw==1
    for i=1:size(group,2)
    for j=1:size(fracTXN{group(1,i),1},1)
        plot(G(1,find(mod([1:size(G,2)],size(group,2))==i*(i~=size(group,2)))),fracTXN{group(1,i),1}(j,1:sess_number(1,group(1,1))),'color',color(i,:),'marker','.')
    end
    end
end
ylabel('Fraction of Arc-TXN neurons (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 size(soi,2)+0.5])
ylim([0 y_lim])

for i=1:size(datum,2)/2
    
[a p]=ttest2(datum(:,2*i-1),datum(:,2*i));
pp=anova1([datum(:,2*i-1) datum(:,2*i)],[],'off');
p_value(i,1)=p;
p_value(i,3)=pp;
p_value(i,2)=ranksum(datum(:,2*i-1),datum(:,2*i));
[h p_value(i,4)]=kstest2(datum(:,2*i-1),datum(:,2*i));
end
p_value
for ref=2%:2
[r c]=find(p_value(:,ref)<0.01);
[rr cc]=find(p_value(:,ref)<0.05 & p_value(:,ref)>0.01);
rr
for i=r'
   line([i-0.2 i+0.2],[y_lim*(0.85+0.1*(ref-1)) y_lim*(0.85+0.1*(ref-1))],'color','k','LineWidth',2);
   text(i,y_lim*(0.87+0.1*(ref-1)),'**','HorizontalAlignment', 'center'...
         ,'LineWidth',2,'FontSize',13,'FontName','arial rounded mt bold')
end
for i=rr'
    line([i-sh i+sh],[y_lim*(0.87+0.1*(ref-1)) y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i-sh i-sh],[100*(M(1,2*i-1)+S(1,2*i-1))+1 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i+sh i+sh],[100*(M(1,2*i)+S(1,2*i))+1 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    text(i,y_lim*(0.89+0.1*(ref-1)),'*','HorizontalAlignment', 'center'...
         ,'LineWidth',2,'FontSize',13,'FontName','arial rounded mt bold')
end
end
xlabel('CA1                         RSC')
end