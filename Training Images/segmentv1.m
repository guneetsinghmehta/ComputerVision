function[pixel_labels]=segmentv1(image)
    figure;imshow(image);
    h=imfreehand;
    roi=getPosition(h);
    vertices=roi;
    mask=roipoly(image,vertices(:,1),vertices(:,2));
    bw=logical(ones(size(image,1),size(image,2)));
    for i=1:3
        temp_image(:,:,1)=image(:,:,i);
        temp_image(:,:,2)=image(:,:,i);
        temp_image(:,:,3)=image(:,:,i);
        bw=bw&region_seg(temp_image,mask,300);
    end
    
    figure;
    ax1=subplot(2,2,1);imshow(image);
    ax2=subplot(2,2,2);imshow(mask);
    ax3=subplot(2,2,3);imshow(bw);
    linkaxes([ax1 ax2 ax3]);
    pixel_labels=bw;
end

function[pixel_label]=activeContourUse(image)
    origImage=image;
%     pixel_labels2=color_segmentation(image);
    image=imadjust(image,stretchlim(image));
    
    % getting a user mask
    figure;imshow(image);
    h=imfreehand;
    roi=getPosition(h);
    vertices=roi;
    mask=roipoly(image,vertices(:,1),vertices(:,2));
    
    if(size(image,3)==3),image=rgb2gray(image);end  
   % mask=logical(ones(size(image)));
    bw=activecontour(image,mask,1000);
%     bw=activecontour(image,mask,1000,'edge','SmoothFactor',0);
    pixel_label=bw;
    
end

function[pixel_labels]=color_segmentation(image)
    %Source code taken from MAthworks from color based segmentation
    %http://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html

    %Color Based segmentation - without cartesian distance
    %he=imread('hello.png');
    he=image;
    cform = makecform('srgb2lab');
    lab_he = applycform(he,cform);
    ab = double(lab_he(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);
    
    %Include the X and Y coordinates for better clustering
    %     [X,Y]=meshgrid(1:nrows,1:ncols);
    %       dist=sqrt(X.*X+Y.*Y);
    %     ab(:,3)=reshape(dist,nrows*ncols,1);
    %     ab(:,4)=reshape(X,nrows*ncols,1);
    %     ab(:,5)=reshape(Y,nrows*ncols,1);

    nColors = 2;%using only 2 because we need to differentiate between shirt and the background
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
        'Replicates',3);
    pixel_labels = reshape(cluster_idx,nrows,ncols);

    end