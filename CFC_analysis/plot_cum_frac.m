function [p_value lifetime]= plot_cum_frac(cum_mat_norm,group,session,color,N,xtick,y_lim,p_class,fitline) %sw for line

G=[];
sh=0.2;
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 420 320]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
if size(group,2)==1
    G=meshgrid(1:session(1,2)-session(1,1)+1,1);
else
for i=1:size(group,2) % X axis, Grid
G=[G; meshgrid(1:session(1,2)-session(1,1)+1,1)-sh+sh*2/(size(group,2)-1)*(i-1)];
end
end
G2=G;
G=reshape(G,1,size(G,1)*size(G,2));
datum{1}=cum_mat_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1);
datum{2}=cum_mat_norm{group(1,2),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1);
for i=1:2
    for j=1:size(cum_mat_norm{group(1,i),session(1,1)-1},1)
    fittg{i,j}=fit([0:(session(1,2)-session(1,1))]',datum{i}(j,:)','exp1');
    lifetime(j,i)=-1/fittg{i,j}.b;
    end
end
lifetime(lifetime==0)=NaN;
M=[mean(cum_mat_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1);...
   mean(cum_mat_norm{group(1,2),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)];
S=[std(cum_mat_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)/sqrt(N(group(1,1),1)); ...
   std(cum_mat_norm{group(1,2),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)/sqrt(N(group(1,2),1))];
fitave{1}=fit(G2(1,:)',100*M(1,:)','exp1');
fitave{2}=fit(G2(2,:)',100*M(2,:)','exp1');
for i=1:session(1,2)-session(1,1)+1 %calculate p-value
    [h p_value(i,1)]=ttest2(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_norm{group(1,2),session(1,1)-1}(:,i));%,'tail','right');
     p_value(i,2)=ranksum(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_norm{group(1,2),session(1,1)-1}(:,i));
  [h p_value(i,3)]=kstest2(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_norm{group(1,2),session(1,1)-1}(:,i));
end

errorbar(G,100*reshape(M,1,size(M,1)*size(M,2)),100*reshape(S,1,size(S,1)*size(S,2)),'LineWidth',2,'linestyle','none','color','k','Capsize',10)

b=bar(G,100*reshape(M,1,size(M,1)*size(M,2)),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
for i=1:size(group,2)    
for j=find(mod([1:1:size(M,1)*size(M,2)],size(group,2))==i*(i~=size(group,2)))
b.CData(j,:)= color(i,:);
end
end

hold all
if fitline
    for i=1:2
    plot(fitave{i},G2(i,:),M(i,:))%,'color',color(i,:),'linestyle','-','LineWidth',2)
    end
end
set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:session(1,2)-session(1,1)+1],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
ylabel('Overlap (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 session(1,2)-session(1,1)+1+0.5])
ylim([0 y_lim])
xtickangle(40)
for ref=p_class
[r c]=find(p_value(:,ref)<0.01);
[rr cc]=find(p_value(:,ref)<0.05 & p_value(:,ref)>0.01);

for i=r'
    line([i-0.2 i+0.2],[y_lim*(0.75+0.1*(ref-1)) y_lim*(0.75+0.1*(ref-1))],'color','k','linewidth',1.5);
    text(i,y_lim*(0.77+0.1*(ref-1)),'**','HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
end
for i=rr'
    line([i-0.2 i+0.2],[y_lim*(0.75+0.1*(ref-1)) y_lim*(0.75+0.1*(ref-1))],'color','k','linewidth',1.5)
    text(i,y_lim*(0.77+0.1*(ref-1)),'*','HorizontalAlignment', 'center','Fontsize',13,'FontName','arial rounded mt bold')
end
end

end