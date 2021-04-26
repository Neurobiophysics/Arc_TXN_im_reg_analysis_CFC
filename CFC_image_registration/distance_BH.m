function distt=distance_BH(X,Y)
for i=1:size(X,1)
    distt(i,1)=0;
    for j=1:size(X,2)
    distt(i,1)=distt(i,1)+(X(i,j)-Y(i,j))^2;
    end
    distt(i,1)=sqrt(distt(i,1));
end
end