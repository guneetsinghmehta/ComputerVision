function[vectorDatabase]=populateVectorDatabase(filenames,scaleDownFactor)
    % Input- imageNames as cell array
    % scale down the image by the factor
    if ~isequal(exist('vl_sift'), 3)
        sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
        orig_path = addpath(sift_lib_dir);
        temp = onCleanup(@()path(orig_path));
    end
    
    vectorDatabase=cell([size(filenames,2) 1]);
    filterSx=11;
    filterSy=11;
    scales=5;orientations=5;
    gaborArray = gaborFilterBank(scales,orientations,filterSx,filterSy);
    for i=1:size(filenames,2)
        %reading and extracting the template images
        image=imread(filenames{1,i});
        image=image(1:scaleDownFactor:end,1:scaleDownFactor:end,:);
        mask=getMask(image);
        image=image.*uint8(mask);
%         figure;imshow(image);title(filenames{1,i});
        
        % find Sift features
        gray_s=rgb2gray(im2single(image));
        [Fs, Ds] = vl_sift(gray_s);
        %dominant color
        [dominantColor,dominant3ColorRatio,colorInfo]=dominantColorFn2(image,mask);
        
        %detect patterns in R,G and B - right now in grayscale
        patternVector=patternVectorFn(image,mask,gaborArray);
        
        %findingBoundaryCoeffs
        boundaryCoeffs=boundaryCoeffsFn(image,mask);
        
        %populate the features
        vectorDatabase{i}.filename=filenames{1,i};
        vectorDatabase{i}.Fs=Fs;
        vectorDatabase{i}.Ds=Ds;
        vectorDatabase{i}.dominantColor=dominantColor;
        vectorDatabase{i}.dominant3ColorRatio=dominant3ColorRatio;
        vectorDatabase{i}.colorInfo=colorInfo;% Not being used
    end
   
end

