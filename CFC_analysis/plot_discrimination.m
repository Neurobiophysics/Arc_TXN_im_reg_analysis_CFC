function [dscm tmp_dat]=plot_discrimination(Freeze,cond_mat,groups,session,class,N)
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 300 300]);

sess_number=[5 4 5 5 6 6 6];
cmap=distinguishable_colors(size(groups,2));
clear dscm tmp_dat datum
for g=1:size(groups,2)
    for s=1:size(session{g},1)
datum{g,s}(1:N(groups(1,g),1),1)=Freeze{groups(1,g),1}(1:N(groups(1,g),1),session{g}(s,2));   
res=reshape(cell2mat(cond_mat{1,class}(groups(1,g),:)),sess_number(1,groups(1,g)),sess_number(1,groups(1,g)),N(groups(1,g),1));
datum{g,s}(1:N(groups(1,g),1),2)=squeeze(res(session{g}(s,1),session{g}(s,2),:));
    end
 tmp_dat{g}=cell2mat(datum(g,:));
 for i=1:size(tmp_dat{g},1)
rsp_tmp_dat=reshape(tmp_dat{g}(i,:),2,[])';     
ff=fit(rsp_tmp_dat(:,1),rsp_tmp_dat(:,2),'poly1');
dscm{g}(i,1)=ff.p1;
 plot(rsp_tmp_dat(:,1),rsp_tmp_dat(:,2),'color',cmap(g,:),'marker','o','linewidth',1)
hold all
%plot(rsp_tmp_dat(:,1),rsp_tmp_dat(:,1)*ff.p1+ff.p2,'color',[1 0 0])
 end
end
set(gca,'linewidth',1.5,'FontSize',13,'FontName','arial rounded mt bold')
xlabel('Freezing','FontSize',13,'FontName','arial rounded mt bold')
ylabel('Reactivation','FontSize',13,'FontName','arial rounded mt bold')
end