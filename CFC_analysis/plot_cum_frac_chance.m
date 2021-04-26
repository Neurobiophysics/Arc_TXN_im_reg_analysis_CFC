function [p_value]= plot_cum_frac_chance(cum_mat_norm,cum_mat_ch_norm,group,session,color,N,xtick,y_lim,p_class) %sw for line

G=[];
sh=0.2;
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 450 300]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
for i=1:2 % X axis, Grid
G=[G; meshgrid(1:session(1,2)-session(1,1)+1,1)-sh+sh*2/(2-1)*(i-1)];
end

G=reshape(G,1,size(G,1)*size(G,2));

M=[mean(cum_mat_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1);...
   mean(cum_mat_ch_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)];
S=[std(cum_mat_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)/sqrt(N(group(1,1),1)); ...
   std(cum_mat_ch_norm{group(1,1),session(1,1)-1}(:,1:session(1,2)-session(1,1)+1),1)/sqrt(N(group(1,1),1))];

for i=1:session(1,2)-session(1,1)+1 %calculate p-value
    [h p_value(i,1)]=ttest(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_ch_norm{group(1,1),session(1,1)-1}(:,i));
    p_value(i,2)=ranksum(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_ch_norm{group(1,1),session(1,1)-1}(:,i));
    [h p_value(i,3)]=kstest2(cum_mat_norm{group(1,1),session(1,1)-1}(:,i),cum_mat_ch_norm{group(1,1),session(1,1)-1}(:,i));
end

errorbar(G,100*reshape(M,1,size(M,1)*size(M,2)),100*reshape(S,1,size(S,1)*size(S,2)),'LineWidth',2,'linestyle','none','color','k','Capsize',10)

b=bar(G,100*reshape(M,1,size(M,1)*size(M,2)),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
for i=1:2 
for j=find(mod([1:1:size(M,1)*size(M,2)],2)==i*(i~=2))
b.CData(j,:)= color(i,:);
end
end

hold all

set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:session(1,2)-session(1,1)+1],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
ylabel('Overlap (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 session(1,2)-session(1,1)+1+0.5])
ylim([0 y_lim])

for ref=p_class
[r c]=find(p_value(:,ref)<0.01);
[rr cc]=find(p_value(:,ref)<0.05 & p_value(:,ref)>0.01);

for i=r'
    line([i-0.2 i+0.2],[y_lim*(0.85+0.1*(ref-1)) y_lim*(0.85+0.1*(ref-1))],'color','k','linewidth',1.5);
    text(i,y_lim*(0.87+0.1*(ref-1)),'**','HorizontalAlignment', 'center','Fontsize',11)
end
for i=rr'
    line([i-0.2 i+0.2],[y_lim*(0.85+0.1*(ref-1)) y_lim*(0.85+0.1*(ref-1))],'color','k','linewidth',1.5)
    text(i,y_lim*(0.87+0.1*(ref-1)),'*','HorizontalAlignment', 'center','Fontsize',11)
end
end
end