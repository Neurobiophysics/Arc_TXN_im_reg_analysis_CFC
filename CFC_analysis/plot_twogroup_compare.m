function plot_twogroup_compare(cond_mat,chan_mat,groups,interest,color,class,ch_class,sw,y_lim,xtick,chance,N) %sw for line
sess_number=[5 4 5 5 6 6 6];

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
G=[];
sh=0.2;

figure2 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 200]);

% Create axes
axes1 = axes('Parent',figure2);
hold(axes1,'on');

for i=1:2 % X axis, Grid
G=[G; meshgrid(1:size(interest,1),1)-sh+sh*2/(2-1)*(i-1)];
end
G=reshape(G,1,size(G,1)*size(G,2));
datum=nan(max(N(groups,1)),2*size(interest,1));
for i=1:size(interest,1) 
[p_mat p compare]=sign_matrix_chance(cond_mat,chan_mat,groups(1,i),class,ch_class,N);
datum(1:size(compare{interest(i,1),interest(i,2)},1),2*i-1:2*i)=compare{interest(i,1),interest(i,2)};
end
M=mean(datum,1,'omitnan');
S=std(datum,0,1,'omitnan')./sqrt(sum(~isnan(datum),1));
errorbar(G,100*reshape(M,1,size(M,1)*size(M,2)),100*reshape(S,1,size(S,1)*size(S,2))...
                             ,'LineWidth',2,'linestyle','none','color','k','Capsize',10)

b=bar(G,100*reshape(M,1,size(M,1)*size(M,2)),'Barwidth',0.7,'LineWidth',2);
b.FaceColor='flat';
for j=1:size(datum,2)
b.CData(j,:)= color(mod(j,size(interest,2))+size(interest,2)*(mod(j,size(interest,2))==0),:);
end
hold all
% set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:size(interest,1)],'XTickLabel',...
%  xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:size(interest,1)],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
if sw==1
    for i=1:size(datum,2)
        plot(zeros(size(datum,1))+G(1,i),100*datum(:,i),'r.','markersize',12)
    end
end
xlim([0.5 size(interest,1)+0.5])
ylim([0 y_lim])
ylabel(ylab,'FontSize',13,'FontName','arial rounded mt bold')
for i=1:size(datum,2)/2
    if chance==1
[a p_value(i,1)]=ttest(datum(:,2*i-1),datum(:,2*i));        
    else
[a p_value(i,1)]=ttest2(datum(:,2*i-1),datum(:,2*i));
    end
p_value(i,2)=ranksum(datum(:,2*i-1),datum(:,2*i));
[a p_value(i,3)]=kstest2(datum(:,2*i-1),datum(:,2*i));
end
p_value
for ref=1%:3
[r c]=find(p_value(:,ref)<0.01);
[rr cc]=find(p_value(:,ref)<0.05 & p_value(:,ref)>0.01);
for i=r'
    line([i-sh i+sh],[y_lim*(0.87+0.1*(ref-1)) y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i-sh i-sh],[100*(M(1,2*i-1)+S(1,2*i-1))+0.5 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i+sh i+sh],[100*(M(1,2*i)+S(1,2*i))+3 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
   text(i,y_lim*(0.89+0.1*(ref-1)),'**','HorizontalAlignment', 'center'...
         ,'LineWidth',2,'FontSize',13,'FontName','arial rounded mt bold')
end
for i=rr'
    line([i-sh i+sh],[y_lim*(0.87+0.1*(ref-1)) y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i-sh i-sh],[100*(M(1,2*i-1)+S(1,2*i-1))+3 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    line([i+sh i+sh],[100*(M(1,2*i)+S(1,2*i))+3 y_lim*(0.87+0.1*(ref-1))],'color','k','LineWidth',1.5);
    text(i,y_lim*(0.89+0.1*(ref-1)),'*','HorizontalAlignment', 'center'...
         ,'LineWidth',2,'FontSize',13,'FontName','arial rounded mt bold')
end
end
% 
% xtickangle(45)
end