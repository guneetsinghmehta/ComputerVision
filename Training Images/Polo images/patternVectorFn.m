function[patternVector]=patternVectorFn(image,mask,gaborArray)
    %We want to find the mean and standard deviation of the image to Gabor
    %filter with different frequencies and angles
    %output - returns patternVector containing
%     1 scales
%     2 orientations
%     3. mean value at each scale and orientation
%     4. std value at each scale and orientation
   
    %Caveats-
    %1. if shirt is slightly tilted then - stripes in horizontal direction
    %will change to stripes in say 30degre - Can live with this
    
    %Working - 
    %1 find GaborFilters
    %2 convolove with image center
    %3 find mean and standard deviation
    
    %1 GaborFilters
    
    [u,v] = size(gaborArray);
    patternVector.scales=u;
    patternVector.orientations=v;
    %2 convolving the center of image -size of filterSx,filterSy
    mask2(:,:,1)=imerode(mask(:,:,1),strel('disk',10));%eroding the boundaries
    mask2=repmat(mask2,[1 1 3]);
    temp=bwdist(mask2(:,:,1));
    temp=1-5*temp/max(temp(:));
    temp(temp<0)=0;
    temp=repmat(temp,[1 1 3]);
    
    image=double(image);
    innerImage=image.*double(mask2);
    outerImage=image.*double(mask-mask2);
    finalImage=innerImage.*temp+outerImage.*temp;
    img=double(rgb2gray(uint8(finalImage)));
    %slowly decay the image to zero
    
    
    f1=figure;
    for i = 1:u
        for j = 1:v
            gaborResult = imfilter(img, gaborArray{i,j});
            gaborResult=mask2(:,:,1).*gaborResult;
%             clf(f1);
%             figure(f1);imagesc(real(gaborResult));colorbar;
%             pause(1);
            patternVector.mean{i,j}=mean(gaborResult(:));
            patternVector.std{i,j}=std(gaborResult(:));
        end
    end
end