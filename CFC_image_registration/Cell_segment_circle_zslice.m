function [centers, radii]=Cell_segment_circle_zslice(I)
%% Control Tower
if nargin<4
Cell_size=200; %pixels
kernel=3;
vac_ratio=0.6;
end
%I=imread('20180606_Arc_oe1_HC_.tif',244);

%%

imfilt=double(imgaussfilt(I, kernel));
imfilt=imfilt*255/max(reshape(imfilt,size(imfilt,1)*size(imfilt,2),1));
imfilt=uint8(imfilt);

imfilt=2^8-1-imfilt;
%circleFinder(imfilt)

%%

detectCircles = @(x) imfindcircles(x,[15 22], ...
	'Sensitivity',0.8600, ...
	'EdgeThreshold',0.07, ...
	'Method','TwoStage', ...
	'ObjectPolarity','Dark');
[centers, radii, metric] = detectCircles(imfilt);
% imagesc(255-imfilt)
% colormap('gray')
% hold all
% for i=1:size(centers,1)
%     plot(centers(i,1),centers(i,2),'ro')
%     text(centers(i,1),centers(i,2)+10,num2str(i),'color','r',...
% 'fontweight','bold')
% end
% 
% axis equal
