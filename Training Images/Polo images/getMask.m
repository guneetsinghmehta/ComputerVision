function[mask]=getMask(image)
    se=strel('disk',3);
    border=20;
    gray=rgb2gray(image);
    gray=padarray(gray,[border border],'replicate');
    mask=edge(gray,'canny');
    mask=imdilate(mask,se);
    mask=imfill(mask,'holes');
    %fill holes - why ?
    mask=imerode(mask,se);
    mask=mask(border+1:end-border,border+1:end-border,:);
    mask=repmat(mask,[1 1 3]);
end