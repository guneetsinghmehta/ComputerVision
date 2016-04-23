function[vectorDatabase,gaborArray]=populateVectorDatabase(filenames,scaleDownFactor)
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
        %dominant color - Generate colors on the basis of a color wheel /
        %color map - import the colormap - hsv- colormap =hsv(256)
        
        [colorHistogram]=colorHistogramFn(image,mask);
        
        %detect patterns in R,G and B - right now in grayscale
        patternVector=patternVectorFn(image,mask,gaborArray);
        
        %findingBoundaryCoeffs
        boundaryCoeffs=boundaryCoeffsFn(image,mask);
        
        %populate the features
        vectorDatabase{i}.filename=filenames{1,i};
        vectorDatabase{i}.Fs=Fs;
        vectorDatabase{i}.Ds=Ds;
        vectorDatabase{i}.colorHistogram=colorHistogram;
        vectorDatabase{i}.patternVector=patternVector;% Not being used
        vectorDatabase{i}.boundaryCoeffs=boundaryCoeffs;% Not being used
    end
   
end

