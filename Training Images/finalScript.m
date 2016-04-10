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
    
    filenames={'s3Front.jpg','s4Front.jpg'};
    scaleDownFactor=8;
    vectorDatabase=populateVectorDatabase(filenames,scaleDownFactor);
    
    %shiftedImage contains one image - shifted and rotated. 
    %queryMatch - returns the name of the matching file
    transformedImage=imread(filenames{1,1});
    transformedImage=transformedImage(4:scaleDownFactor:end,4:scaleDownFactor:end,:);
    transformedImage=imrotate(transformedImage,1);
    queryMatchResult=queryMatch(vectorDatabase,transformedImage);
    display(vectorDatabase);
end

function[vectorDatabase]=populateVectorDatabase(filenames,scaleDownFactor)
    % Input- images as cell array
    % scale down the image by the factor
    
    vectorDatabase=cell(size(filenames,2));
    for i=1:size(filenames,2)
        image=imread(filenames{1,i});
        image=image(1:scaleDownFactor:end,1:scaleDownFactor:end,:);
        % find Sift features
        
        gray_s=rgb2gray(im2single(image));
        [Fs, Ds] = vl_sift(gray_s);
        % Each column of Fs is a feature frame and has the format [X; Y; S; TH],
        % where X, Y is the (fractional) center of the frame, S is the scale and TH
        % is the orientation (in radians)
        % Ds is the descriptor of the corresponding frame in F.
        % use DS as - [matches, scores] = vl_ubcmatch(Ds, Dd);
        
        %populate the sift features
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
        avgScore=mean(scores(1:10));
        if(avgScore<minScore)
            index=i;
            minScore=avgScore;
        end
    end
    queryMatchResult=vectorDatabase{i}.filename;
end