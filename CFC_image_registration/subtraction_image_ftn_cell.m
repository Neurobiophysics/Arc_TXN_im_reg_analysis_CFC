%  Autofluorescence subtraction code
%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% This code removes the autofluorescent signal from red channel (channel 1)
% from green channel (channel 2) accuracy exceed 90%.

% INPUTS 

% Two channel image cell matrix im{1}=auto im{2}=signal
% 

% OUTPUTS
% Subtracted image matrix

% MODIFICATION HISTORY : 
%           Written by Byung Hun Lee, Deptartment of Physics and Astronomy, Seoul National University, 6/11/2018.

function subtraction=subtraction_image_ftn_cell(im,scale)
        stack=double(im{1});
        stackG=double(im{2});

%         R=max(max(max(stack,[],3)));
%         G=max(max(max(stackG,[],3)));

for i=1:size(stack,3)
    
    resR=reshape(stack(:,:,i),size(stack(:,:,i),1)*size(stack(:,:,i),2),1);
    resR(resR>4080)=0;
    resG=reshape(stackG(:,:,i),size(stackG(:,:,i),1)*size(stackG(:,:,i),2),1);
    resG(resR>4080)=0;
    R=max(max(resR));
    G=max(max(resG));
    if nargin < 2
        scale=G/R;
end
       subtraction(:,:,i)=stackG(:,:,i)-stack(:,:,i)*scale;  
end
% ratio=G/R;
%          subtraction=im{2}-im{1}/ratio;
        subtraction=uint16(subtraction);
        
        
end
