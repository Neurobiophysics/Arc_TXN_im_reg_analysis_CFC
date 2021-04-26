%%
% MODIFICATION HISTORY : 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy,
%           Seoul National University, 2019.04.03.
%%%%%%%%%%%%%%%%%%%%%%%%
% Control Tower
%%%%%%%%%%%%%%%%%%%%%%%%
clear
new_data=true;
group=7;
color=[0.2 0.8 0.8; 0.3 0.5 0.5; 0.8 0.2 0.8; 0.5 0.3 0.5];
pthh=['H:\Image_data\OlympusTPM\Invivo_images_CFC\'];
nm=['rst_combine_' date '.mat'];
cat={'HPC-AAA', 'HPC-AAB', 'RSC-AAB', 'RSC-AAB','HPC-Remote', 'RSC-Remote','PFC-Remote'};

if new_data
    for i=1:group
[fnm{i} pth{i}]=uigetfile('.mat',['Select the analyzed mouse data ' num2str(i) 'th Group'],'Multiselect','on');
    end
else
   if exist(fullfile([pthh nm]))
       load(fullfile(pthh,nm))
   else error('No result file. Check !') 
   end
end

%% Making omitna & thresholded data, Variable : 'omitna_data'
for i=1:size(fnm,2) %mouse
    N(i,1)=size(fnm{1,i},2);
    for j=1:size(fnm{1,i},2)
    mousedat{i,j}=importdata([pth{1,i} fnm{1,i}{1,j}]);
    [omitna_data{i,j} thr_data{i,j}]=omitna(mousedat{i,j});
    end
end
save([pthh nm],'omitna_data','mousedat','thr_data','fnm','N')
%% Calculate FracTXN and Freezing
xtick={'HC','CFC','Ret 1','Ret 2','Ret 3','Ret4'}; color=[.8 .2 .8; .5 .8 .8;.8 .2 .8 ;.8 .5 .8];
xtick2={'A          B','A           B'};
fztick={'Before shock','After shock','Ret 1','Ret 2','Ret 3','Ret 4'};
[fracTXN fracTXN_norm]=fraction_TXN(omitna_data,thr_data,2); % 1: fraction in each day, 2: fraction of TXN among available cells.
% Freeze=freezing_rate(mousedat,N);
plot_TXN(fracTXN,[6],0,color,N,xtick,45)
%plot_TXN_AB(fracTXN,group,4,xtick,y_lim)
% p=plot_TXN_norm(fracTXN_norm,[1],0,color,N,xtick,150);
%inform=plot_inf2(fracTXN,[4],0,color,N,xtick,1.5,omitna_data);
%plot_ctxB(fracTXN,[1 2 ;3 4],[4 4 ;5 5],2,color,N,xtick2,46)
%plot_freeze(Freeze,[5 6],2,[0 0 0;0.8 0.3 0.1],N,fztick,100,[1 6])
%% Conditional probability
cond_mat=cond_matrix(omitna_data,N);
chan_mat=chance_matrix(omitna_data,N);
%% plot Conditional probability
plot_matrix(cond_mat,4,mousedat,[1500 900],N,1,[0 0.7])  % 1:overlap, 2: Jaccard, 3:Cond_prob, 4:Guzowski 5: angle 6: distance
                                                         % 1: imshow, 2: imagesc
%% Calculate p-value
clear compare compare_ch
group=4; class=1; ch_class=1; %1: Overlap ch, 2: Reactivation Ch, Reactivation Neg.
groups=[1 2];
color=[0.8 0.2 0.8; 0.2 0.1 0.2];
[p_mat p_value compare]=sign_matrix(cond_mat,groups,class,N);    
[p_mat_ch p_value_ch compare_ch]=sign_matrix_chance(cond_mat,chan_mat,group,class,ch_class,N); %group,class,ch_class
%[compare_OdC]=overlap_div_chan(cond_mat,chan_mat,groups,N);
%plot_matrix_p(cond_mat,chan_mat,group,class,ch_class,p_mat_ch,N,[0 0.7]) %number values, gruop, class, class_ch
%plot_matrix_p_two_group(cond_mat,groups,class,p_mat,p_value,N,[0 0.5],1) % 3 = p_value class, 1:ttest, 2:MW, 3:KS
%plot_twogroup_compare(cond_mat,chan_mat,groups,[2 3;2 3],color,class,ch_class,0,50,{'Day 1','Day 7'},1,N) 
% group, session, color, class, chance class,
plot_cmpr_int(compare_ch,[2 5],color,class,0,33,{'C{\bf\cap}B','R1{\bf\cap}R2','R2{\bf\cap}R3','R3&R4'},1)  
% 1:sw, 10: y_lim, Chance
%% Cumulative fraction
color=[0.8 0.2 0.8; 0.2 0.1 0.2]; group=6; session=[2 6]; groups=[5 6];
%xtick={'CFC','C{\bf\cap}R1','C{\bf\cap}R1{\bf\cap}R2','C{\bf\cap}R1{\bf\cap}R2{\bf\cap}R3','C{\bf\cap}R1{\bf\cap}R2{\bf\cap}R3{\bf\cap}R4'};
xtick={'CFC','C~R1','C~R2','C~R3','C~R4'};
[cum_mat cum_mat_norm cum_mat_ch cum_mat_ch_norm]=cumulative_frac(omitna_data,N,[2 2 2 2 2 2]);
%[p lifetime]=plot_cum_frac(cum_mat,groups,session,color,N,xtick,50,1,0) % value p : 1st column = ttest, 2nd column =MW, 3rd = KS, fitline =1, true
p=plot_cum_frac_chance(cum_mat,cum_mat_ch,group,session,color,N,xtick,40,1) % group, sesssion, 
%% Bayesian probability 
color=[0.8 0.2 0.8; 0.5 0.3 0.5];
Bay_prob=bayesian_prob(omitna_data,N);
plot_bay(Bay_prob,[1 3;2 3],0,color,N,{'RSC B+','RSC B-'},50)

%% Drawing Venn diagram
tick_coord=[-0.3 -0.30;0.55 -0.30;0.2 0.63];
plot_venn(omitna_data,[3],[2],[3 4 5],N,tick_coord) % group, cond, session of interest

%% Plot circle plot
cir_im=plot_hist_circle(omitna_data,[1 1],[2 4],1); % [group mouse] [start end_session]
%% Plot Freezing Reactivation scatter plot
color=[repmat([0 0.45 0.7],5,1); [0.8 0.47 0.65]];
groups=[3 4];
%[0.8 0.2 0.8;1 0.5 0;0.8 0.2 0.8;0.8 0.2 0.8];
%[d d_cell]=plot_frz_reactivation(Freeze,cond_mat,[3 2 3;3 2 4;3 2 5;4 2 3;4 2 4;4 2 5],1,N,color);
%[Group interest session ex, CFC Ret = 2 3], Class
%[rho,pval]=corr(d(:,1),d(:,2))%,'type','Pearson','rows','pairwise')
%dp=plot_place_activation(T,fracTXN,[1 2 5],N,color,2);% 1: distance, 2: standard deviation
[dscm tmp_dat]=plot_discrimination(Freeze,cond_mat,groups,{[2 3;2 4;2 5],[2 3;2 4;2 5]},3,N);
%% Plot tree plot
group=4;
tree=plot_tree(omitna_data,N,1,group); % 1:overlap, 2:Conditional; group