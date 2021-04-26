function d=plot_place_activation(tracks,fracTXN,groups,N,color,sw)
sess_number=[5 4 5 5 6 6 6];
groups=groups';
%g_soi = group, sess1 (CFC), sess2 (ret);
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);
d=[];
switch sw
    case 1
tr_dist=cellfun(@track_distance,tracks);
Xlab={'Distance (A.U.)'};
xlim([0 10000])
    case 2
tr_dist=cellfun(@track_std,tracks);
Xlab={'Standard deviation'};
xlim([0 100])
end
for i=1:size(groups,1) 
datum{i}=nan(N(groups(i,1),1),2);
datum{i}(1:N(groups(i,1),1),1)=tr_dist(groups(i,1),1:N(groups(i,1)))';
datum{i}(1:N(groups(i,1),1),2)=fracTXN{groups(i,1),1}(:,2);
plot(datum{i}(:,1),100*datum{i}(:,2),'marker','.','markersize',18,'linestyle','none','color',color(i,:),'LineWidth',1)
hold all
d=[d;datum{i}];
end
ylim([0 50])
set(gca,'LineWidth',1,'FontSize',10);
xlabel(Xlab,'FontName','arial rounded mt bold','FontSize',12)
ylabel(['Fraction of Arc-Txn neurons (%)'],'LineWidth',1,...
    'FontSize',12,...
    'FontName','arial rounded mt bold','HorizontalAlignment', 'center');
[rho,pval]=corr(d(:,1),d(:,2),'type','Pearson','rows','pairwise');
text(50,50,['Corr = ' num2str(rho) ', p = ' num2str(pval)]);
end
function r=track_distance(tracks)
r=0;
for i=1:size(tracks,1)-1
    r=r+sqrt(sum((tracks(i+1,:)-tracks(i,:)).^2));
end
end
function r=track_std(tracks)
r=mean(std(tracks,0,1));
end