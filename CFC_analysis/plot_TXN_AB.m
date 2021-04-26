function plot_TXN_AB(fracTXN,group,day,xtick,y_lim) %sw for line
sess_number=[5 4 5 5 6 6 6];

figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
G=[1:day];
d=fracTXN{group(1,1),1}(:,1:day);
d=[d; [fracTXN{group(1,2),1}(:,1:day-1) NaN(size(fracTXN{group(1,2),1},1),1)]];
d2=fracTXN{group(1,2),1}(:,day);
M=mean(d,1,'omitnan'); S=std(d,0,1,'omitnan')./sqrt(sum(~isnan(d),1));
M2=mean(d2,1,'omitnan'); S2=std(d2,0,1,'omitnan')./sqrt(sum(~isnan(d2),1));
    errorbar(G,100*M,100*S,...
        'LineWidth',2,'linestyle','-','color','k','Capsize',10,'marker','+','markersize',10)
    hold all
    errorbar(day,100*M2,100*S2,...
        'LineWidth',2,'linestyle','none','color',[0.9 0.6 0],'Capsize',10,'marker','+','markersize',10)


set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:sess_number(1,group(1,1))],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);

ylabel('Fraction of Arc-TXN neurons (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 day+0.5])
ylim([0 y_lim])
end