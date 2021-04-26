function plot_freeze(Freeze,group,sw,color,N,xtick,y_lim,soi) %sw for line
sess_number=[5 4 5 5 6 6 6];
G=[];
sh=0.2;
figure3 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 400 250]);

% Create axes
axes1 = axes('Parent',figure3);
hold(axes1,'on');
    G=meshgrid(1:6,1);
if size(group,1)>1
    datum=zeros(size(Freeze{group(1,1),1},1)+size(Freeze{group(1,2),1},1)...
               +size(Freeze{group(2,1),1},1)+size(Freeze{group(2,2),1},1),6);
else
    datum=zeros(size(Freeze{group(1,1),1},1)+size(Freeze{group(1,2),1},1),6);
end
    datum(datum==0)=NaN;
    tmp=[];
    for i=1:size(group,2)
    tmp=[tmp;Freeze{group(1,i),1}(:,soi(1,1):soi(1,2))];
    end
    datum(1:size(tmp,1),soi(1,1):soi(1,2))=tmp;
    if size(group,1)>1
    datum(size(tmp,1)+1:size(tmp,1)+size(Freeze{group(2,1),1},1)+size(Freeze{group(2,2),1},1),soi(1,2)+1)...
        =[Freeze{group(2,1),1}(:,soi(2,1));Freeze{group(2,2),1}(:,soi(2,2))];
    end 
    M=mean(datum,1,'omitnan');
    n(soi(1,1):soi(1,2),1)=N(group(1,1),1)+N(group(1,2),1);
    if size(group,1)>1
    n(soi(1,2)+1,1)=N(group(2,1),1)+N(group(2,2),1);
    end
    S=std(datum,0,1,'omitnan')./sqrt(n');
    
    errorbar(G(1,soi(1,1):soi(1,2)),100*M(1,soi(1,1):soi(1,2)),100*S(1,soi(1,1):soi(1,2)),...
        'LineWidth',2,'color',color(1,:),'Capsize',8,'marker','+')
hold all    
  if size(group,1)>1
    errorbar(G(1,soi(1,2)+1),100*M(1,soi(1,2)+1),100*S(1,soi(1,2)+1),...
        'LineWidth',2,'linestyle','none','color',color(2,:),'Capsize',8,'marker','+')
    text(soi(1,2)+1,100*M(1,soi(1,2)+1)+S(1,soi(1,2)+1)+5,'****','HorizontalAlignment', 'center'...
         ,'LineWidth',2,'FontSize',13,'FontName','arial rounded mt bold','color',color(2,:))
      end
set(gca,'FontSize',8,'LineWidth',1,'XTick',[1:1:soi(1,2)+(size(group,1)>1)],'XTickLabel',...
 xtick,'FontName','arial rounded mt bold','FontSize',13,'LineWidth',2);
if sw==1
    for i=1:size(group,2)
    for j=1:size(fracTXN{group(1,i),1},1)
        plot(G(1,find(mod([1:size(G,2)],size(group,2))==i*(i~=size(group,2)))),fracTXN{group(1,i),1}(j,1:sess_number(1,group(1,1))),'color',color(i,:),'marker','.')
    end
    end
end
ylabel('Freezing rate (%)','LineWidth',2,'FontSize',13,...
    'FontName','arial rounded mt bold')
xlim([0.5 6+0.5])
ylim([0 y_lim])
end