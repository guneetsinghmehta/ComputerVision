function[]=finalScript()
    %Adding Sift Library
    if ~isequal(exist('vl_sift'), 3)
        sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
        orig_path = addpath(sift_lib_dir);
        temp = onCleanup(@()path(orig_path));
    end

    %read two images
    % find Sift features
    % read another image - shifted red shirt, find sift features
    % match the sift features
    
    filenames={'polo1.jpg','polo2.jpg','polo3.jpg','polo4.jpg','polo5.jpg','polo6.jpeg'};
    scaleDownFactor=1;
    vectorDatabase=populateVectorDatabase(filenames,scaleDownFactor);
    display(vectorDatabase);
    
    %shiftedImage contains one image - shifted and rotated. 
    %queryMatch - returns the name of the matching file
    transformedImage=imread(filenames{1,1});
    transformedImage=transformedImage(4:scaleDownFactor:end,4:scaleDownFactor:end,:);
    transformedImage=imrotate(transformedImage,180);
    maskTemp=getMask(transformedImage);
    transformedImage=transformedImage.*uint8(maskTemp);
    queryMatchResult=queryMatch(vectorDatabase,transformedImage);
    display(queryMatchResult);
    
    transformedImage=imread(filenames{1,2});
    transformedImage=transformedImage(4:scaleDownFactor:end,4:scaleDownFactor:end,:);
    transformedImage=imrotate(transformedImage,90);
    maskTemp=getMask(transformedImage);
    transformedImage=transformedImage.*uint8(maskTemp);
    queryMatchResult=queryMatch(vectorDatabase,transformedImage);
    display(queryMatchResult);
end

function[vectorDatabase]=populateVectorDatabase(filenames,scaleDownFactor)
    % Input- images as cell array
    % scale down the image by the factor
    
    vectorDatabase=cell([size(filenames,2) 1]);
    for i=1:size(filenames,2)
        %reading and extracting the template images
        image=imread(filenames{1,i});
        image=image(1:scaleDownFactor:end,1:scaleDownFactor:end,:);
        mask=getMask(image);
        image=image.*uint8(mask);
        figure;imshow(image);title(filenames{1,i});
        
        % find Sift features
        gray_s=rgb2gray(im2single(image));
        [Fs, Ds] = vl_sift(gray_s);
    
        %populate the features
        vectorDatabase{i}.filename=filenames{1,i};
        vectorDatabase{i}.Fs=Fs;
        vectorDatabase{i}.Ds=Ds;
    end
end

function[queryMatchResult]=queryMatch(vectorDatabase,queryImage)
    s1=size(vectorDatabase,1);
    [Fq,Dq]=vl_sift(rgb2gray(im2single(queryImage)));
    minScore=intmax;
    index=0;
    for i=1:s1
        Fs=vectorDatabase{i}.Fs;
        Ds=vectorDatabase{i}.Ds;
        [matches, scores] = vl_ubcmatch(Ds, Dq);
        scores=sort(scores);
        if(size(scores,2)>=10)
            avgScore=mean(scores(1:10));
        else
            avgScore=mean(scores);
        end
            
        if(avgScore<minScore)
            index=i;
            minScore=avgScore;
        end
    end
    queryMatchResult=vectorDatabase{index}.filename;
end