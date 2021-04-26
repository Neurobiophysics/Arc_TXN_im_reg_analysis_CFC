function cc=plot_frz_cum(Freeze,cum_mat,groups,session)
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],'Renderer','painters','position',[100 100 300 300]);

sess_number=[5 4 5 5 6 6 6];
cmap=distinguishable_colors(size(groups,2));

for g=1:size(groups,2)
    datum_pool{g}=[];
    for gg=groups{g}
    datum=[Freeze{gg,1}(:,session(1,g)) cum_mat{gg,1}(:,session(1,g)-1)];
    datum_pool{g}=[datum_pool{g}; datum];
    end
    datum_pool{g}=datum_pool{g}*100;
plot(datum_pool{g}(:,1),datum_pool{g}(:,2),'marker','.','linestyle','none','color',cmap(g,:),'markersize',20)
hold all
%[cc(g,1) cc(g,2)]=corr(datum_pool{g}(:,1),datum_pool{g}(:,2),'row','pairwise');
[cc(g,1) cc(g,2)]=corr(datum_pool{g}(:,1),datum_pool{g}(:,2),'Type','Pearson','Tail','right');

set(gca,'LineWidth',1,'FontSize',15);
xlabel('Freezing (%)','FontName','arial rounded mt bold','FontSize',15)
ylabel(['Overlap (%)'],'LineWidth',1,...
    'FontSize',15,...
    'FontName','arial rounded mt bold','HorizontalAlignment', 'center');
%text(50,50,['Corr = ' num2str(cc(g,1)) ', p = ' num2str(cc(g,2))],'FontSize',10,'FontName','arial rounded mt bold');
ff=fit(datum_pool{g}(:,1),datum_pool{g}(:,2),'poly1');
plot([10:10:80],ff([10:10:80]),'color',cmap(g,:)+0.1,'linestyle','--','linewidth',2.5)
end
ylim([0 40])
end

