function cir_im=plot_hist_circle(omitna_data,mouse,sess,sw)
sz=1024;
figure1 = figure('InvertHardcopy','off','PaperUnits','centimeters',...
    'Color',[1 1 1],...
    'Renderer','painters','position',[100 100 400 size(mouse,1)*400]);
rad=20;
% mouse = [group , #th mouse] 
cd=[2 1 1;1 2 1;1 1 2;2 2 1;2 1 2;1 2 2; 2 2 2];
for j=1:size(mouse,1)
cir_im=zeros(sz,sz);
if sw
for c=1:size(cd,1)
    l=[];
    for d1=1:size(cd,2)
        l=[l omitna_data{mouse(j,1),mouse(j,2)}(:,2+sess(1,1)+d1)==cd(c,d1)];
    end
    list=find(sum(l,2)==size(cd,2));
    cir_im(find(createCirclesMask([sz sz],round(omitna_data{mouse(j,1),mouse(j,2)}(list,1:2)),zeros(size(list,1),1)+rad)))=c;
end
else
for i=1:sess(1,2)-sess(1,1)+1
    l=find(sum(omitna_data{mouse(j,1),mouse(j,2)}(:,3+sess(1,1):3+sess(1,2))==2,2)==i);
    cir_im((createCirclesMask([sz sz],round(omitna_data{mouse(j,1),mouse(j,2)}(l,1:2)),zeros(size(l,1),1)+rad)))=i+1;
end
end
s=subplot(size(mouse,1),1,j);

%c=[0.2 1 1];
if sw
    imagesc(cir_im)
axis equal tight off
col_map=[0 0 0;(cd(1:3,:)-1)/2;3/4*(cd(4:6,:)-1);[1 1 1]];    
%col_map=[0 0 0;distinguishable_colors(7)];    
else
    imagesc(cir_im-1)
axis equal tight off
if sess(1,2)==5
col_map=[0 0 0
         0.15 0.15 0.15
         0.1 0.2 0.5
         0.1 0.4 0.15
         0.5 0.6 0.1
         %0.8 0.5 0.1;
         1 0.1 0
         %0.2 0 1
         ];
else
     col_map=[0 0 0
         0.15 0.15 0.15
         0.1 0.2 0.5
         0.1 0.4 0.15
         0.5 0.6 0.1
         0.8 0.5 0.1;
         1 0.1 0
         %0.2 0 1
         ];
end 
end
% for i=1:sess(1,2)-sess(1,1)+1 
%     col_map=[col_map; c(1,1)*i/(sess(1,2)-sess(1,1)+1) c(1,2)*i/(sess(1,2)-sess(1,1)+1) c(1,2)*i/(sess(1,2)-sess(1,1)+1)];
% end
%colormap(fliplr(col_map));
colormap(col_map);
hold all
cc=colorbar(s,'limits',[0.7 sess(1,2)-0.8],'Ticks',[0:sess(1,2)-sess(1,1)+1],...
         'TickLabels',{'Not activated','1','2','3','4','5'},'fontweight','bold','location','southoutside','Fontsize',13,'FontName','arial rounded mt bold');
     cc.Label.String = 'Activated times';
%colormap([0.2 0.2 0.2; 0.4 0.2 0.2; 0.6 0.3 0.2; 0.8 0.4 0.2;1 0.5 0.2])
end
end