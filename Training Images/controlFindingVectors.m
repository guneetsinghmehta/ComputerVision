function[]=controlFindingVectors()
    %Reads two images, opens up a window,asks the user to draw one mask
    %each for the images, saves the mask.
    % find the vectors of the image within the mask
   addDependencies;
   if ~isequal(exist('vl_sift'), 3)
        sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
        orig_path = addpath(sift_lib_dir);
        % Restore the original path upon function completion
        temp = onCleanup(@()path(orig_path));
    end
    imageNames={'s4Front.jpg','s3Front.jpg'};
   f1=figure;
   vector=[];%Stores all vectors
   for i=1:size(imageNames,2)
       image=imread(imageNames{1,i});
       image=image(1:8:end,1:8:end,:);%To make the image smaller
      %makeMasks(image,i);
       
       name=['mask' num2str(i) '.png'];
       mask=imread(name);
       mask=logical(mask);
       figure;imshow(mask);colorbar;
       vectorDirectory{i}=getVector(image,mask);
   end
       
   index=findQuery(vectorDirectory,vectorDirectory{1,1});%index should come out to be 1
   resultImage=imread(imageNames{1,index});
   resultImage=resultImage(1:8:end,1:8:end,:);
   figure;imshow(resultImage);title('Queried Image');%Queried Image 
end

function[index]=findQuery(vectorDir,vector)
    s1=size(vectorDir{1,1},2);
    for i=1:s1
        if(isequal(vector,vectorDir{1,i}))
            index=i;break;
        else
           index=-1; 
        end
    end  
end

function[]=addDependencies()
    if ~isequal(exist('vl_sift'), 3)
        sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
        orig_path = addpath(sift_lib_dir);
        % Restore the original path upon function completion
        temp = onCleanup(@()path(orig_path));
    end
end

function[mask]=makeMasks(image,i)
    f1=figure;imshow(image);
    h=imfreehand;
    roi=getPosition(h);
    vertices=roi;
    mask=roipoly(image,vertices(:,1),vertices(:,2));
    mask=uint8(255*double(mask));
    name=['mask' num2str(i) '.png'];
    imwrite(mask,name);
    close(f1);
end

function[vector]=getVector(image,mask)
    mat=repmat(mask,[1,1,3]);
    mat=uint8(mat);
    imgs=image.*mat;
    imgs = im2single(imgs); gray_s = rgb2gray(imgs);
    [Fs, Ds] = vl_sift(gray_s);

    temp=rgb2hsv(image);
    maxColor=max(max(temp(:,:,1)));
    colors=uint8(temp(:,:,1)*255);%Colors now contains 255 separate intensity colors
    h=imhist(colors);
    [A,index]=sort(h,'descend');
    dominantColor=index(1);
    
    vector={Fs,Ds,dominantColor};
end