function Freeze=freezing_rate(mousedat,N)

for i=1:size(mousedat,1)
    for j=1:N(i,1)
f=table2array(struct2table(mousedat{i,j}.Cell.Freeze));
 Freeze{i,1}(j,1:size(f,2))=f;
    end
end