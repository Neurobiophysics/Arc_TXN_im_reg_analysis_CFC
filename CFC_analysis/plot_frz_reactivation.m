function [d datum]=plot_frz_reactivation(Freeze,cond_mat,g_soi,class,N,color)
sess_number=[5 4 5 5 6 6 6];
%g_soi = group, sess1 (CFC), sess2 (ret);
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 200 200]);
d=[];
switch class
    case 1
        ylab={'Overlap (%)'};
    case 2
        ylab={'Jaccob similarity (%)'};
    case 3
        ylab={'Reactivation (%)'};
    case 4
        ylab={'Guzowski similarity (%)'};
    case 5
        ylab={'Angle'};
    case 6
        ylab={'Distance'};
end

for i=1:size(g_soi,1) 
datum{i}=nan(N(g_soi(i,1),1),2);
datum{i}(1:N(g_soi(i,1),1),1)=Freeze{g_soi(i,1),1}(1:N(g_soi(i,1),1),g_soi(i,3));
res=reshape(cell2mat(cond_mat{1,class}(g_soi(i,1),:)),sess_number(1,g_soi(i,1)),sess_number(1,g_soi(i,1)),N(g_soi(i,1),1));
datum{i}(1:N(g_soi(i,1),1),2)=squeeze(res(g_soi(i,2),g_soi(i,3),:));
plot(100*datum{i}(:,1),100*datum{i}(:,2),'marker','.','markersize',18,'linestyle','none','color',color(i,:),'LineWidth',1)
hold all
d=[d;datum{i}];
end
xlim([0 100])
%ylim([0 30])
set(gca,'LineWidth',1,'FontSize',10);
xlabel('Freezing rate (%)','LineWidth',1,'FontName','arial rounded mt bold','FontSize',12)
ylabel(ylab,'LineWidth',1,'FontName','arial rounded mt bold','FontSize',12)

end