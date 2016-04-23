function[prop]=boundaryCoeffsFn(image,mask3D)
%outputs properties as
%xceenter,ycenter,orientation,roundedness,normMaxInteria

% Temporary - returns normalized fft of the boundary with n points. points
% are scaled down and then the fft is divided by the max absolute value of
% fft
% distance calculated in queryMatch2.m

    %input - image is 3D, mask3D is 3D
    %output - normalized fft coeffs magnitude
    %find 500(n) points using normalize boundary
    %z=x+yi - convert
%     1 Done subtract the mean of x and mean of y - not center of object
%     1.5 Divide by max distance to make it scale invariant
%     2 Done find dft using fft
%     3 Done find the absolute values of fft
%     4 
%     5 first element - DC component - discard this - translation invariant
%     6 discard high frequencies - say 100 onwards
%     7 to make reflection invariant - just reverse the direction of traversal -
%     in effect compare with the reversed conjugate of the original - also 
%     compare with reverse conjugate and output the minimum distance
%     
%     8 ***CAUTION - to make rotation invariant - remove the imaginary part of the
%     fft just after taking the fft***
%     9 similarity score function - on a scale of 0 to 1
%     
%     Tests
%     1. Same image
%     2. Image of two t shirts
%     3. one shirt one t shirt
%     4. one shirt and one trouser
    
    fftCoeffs=0;
    mask=mask3D(:,:,1);
    % define the number of points on each boundary
    n=500;

    % find the boundary
    boundary=bwboundaries(mask);
%     if(size(boundary,1)>1||size(boundary,2)>1),error('more than one boundary. check mask');return ;end
    maxSize=0;
    for i=1:size(boundary,1)
        if(size(boundary{i,1},1)>maxSize)
           maxSize= size(boundary{i,1},1);
           maxSizeBoundary=boundary{i,1};
        end
    end
    boundary=maxSizeBoundary;%finding size of maximum size - smaller boundaries
    %correspond to smaller artifact
    display(maxSize);
    
    % find points on the boundary s1, s2=n-s1
    [x,y]=normalizeBoundary(boundary,n);
    figure;imshow(image);hold on;plot(y,x,'*');%plots the normalized shape
        %show the boundary 
%   figure;imshow(image);hold on;plot(y,x,'*');
    
    xc=mean(x);
    yc=mean(y);
    x=x-xc;
    y=y-yc;
    dist=max(abs(x+y*(1i)));
    x=x/dist;
    y=y/dist;
    
    Xfft=fft(x);
    Yfft=fft(y);
    Xfft(20:end)=0;
    Yfft(20:end)=0;
    x=ifft(Xfft);
    y=ifft(Yfft);
    
    prop=compute2DProperties(image(:,:,1),mask(:,:,1));
    
    figure;imshow(image);hold on;plot(y+yc,x+xc,'*');%plots the normalized shape
    Zfft=0;
end

function[dist]=findDist(Zfft,a,b)
    dist=0;
    for i=1:size(Zfft(1,:),2)
        dist=dist+abs(Zfft(a,i)-Zfft(b,i));
    end
end

function[x,y]=normalizeBoundary(boundary,n)
%Finds a boundary containing n points. If the boundary has less than n
%points then interpolation is done.
%If boundary has more than n points then the other points are thrown
    s1=size(boundary,1);s2=n-s1;
    x=zeros(1,n);
    y=zeros(1,n);
    if(s2==0)
        x=boundary(:,1);
        y=boundary(:,2);
    elseif(s2<0)
       %more points than needed - need to downsample
       %Checked - working
       a=1;b=s1;%here s1>n
       diff=(b-a)/n;  
       for i=1:n
           index=a+(i-1)*diff;
           index=floor(index);
           x(i)=boundary(index,1);
           y(i)=boundary(index,2);
       end
    elseif(s2>0)
        queryIndices=indices(boundary(:,1),n);%have size s2
        x1=boundary(:,1);
        x2=floor(interp1(1:s1,x1,queryIndices));
        y1=boundary(:,2);
        y2=floor(interp1(1:s1,y1,queryIndices));
        
        index=1;p=1;
        for i=1:s1
            x(index)=x1(i);
            index=index+1;
            if(queryIndices(p)==i)
               x(index)=x2(p);
               p=p+1;
               index=index+1;
            end
        end
        
        index=1;p=1;
        for i=1:s1
            y(index)=y1(i);
            index=index+1;
            if(queryIndices(p)==i)
               y(index)=y2(p);
               p=p+1;
               index=index+1;
            end
        end
        display(1);
    end
end

function[x2]=indices(x,n)
     s1=size(x,1);s2=n-s1;
     x2=zeros([1,s2]);
    for i=1:s2
       x2(i)=i*s1/s2;
    end
end

function [props] = compute2DProperties(orig_img, labeled_img)
orig_img=double(orig_img);
labeled_img=double(labeled_img);
    numObjects=max(labeled_img(:));
    out_img=orig_img;pause(1);
    f1=figure;imshow(uint8(out_img));
    for i=1:numObjects
%         showComponent(labeled_img,i);
       
       [xcenter,ycenter]=findCenter(labeled_img,i);
       
       [maxInertia,minInertia,orientation,roundedness,minDist,maxDist]=findProps(labeled_img,i,xcenter,ycenter);
       figure(f1);text(ycenter,xcenter,['*' num2str(xcenter) ' ' num2str(ycenter) ' - ' num2str(orientation)],'Color',[1 0 0]);hold on;
       props{i}.xcenter=xcenter;
       props{i}.ycenter=ycenter;
       props{i}.orientation=orientation;
       props{i}.roundedness=roundedness;
       props{i}.normMaxInteria=maxInertia/(maxDist^2);
    end
    out_img=saveAnnotatedImg(f1);
    
end

function [xcenter,ycenter]=findCenter(labeled_image,label)
    [s1,s2]=size(labeled_image);
    xcenter=0;ycenter=0;count=0;
    for i=1:s1
        for j=1:s2
            if(labeled_image(i,j)==label),xcenter=xcenter+i;ycenter=ycenter+j;count=count+1;end
        end
    end
    xcenter=floor(xcenter/count);
    ycenter=floor(ycenter/count);
end

function [maxInertia,minInertia,orientation,roundedness,minDist,maxDist]=findProps(image,label,xcenter,ycenter)
   [s1,s2]=size(image);
   a=0;b=0;c=0;count=0;
   minDist=realmax;
   maxDist=realmin;
   for i=1:s1
       for j=1:s2
            if(image(i,j)==label)
                a=a+(i-xcenter)^2;
                b=b+(i-xcenter)*(j-ycenter);
                c=c+(j-ycenter)^2;
                count=count+1;
                if (sqrt((i-xcenter)^2+(j-ycenter)^2)<minDist),minDist=sqrt((i-xcenter)^2+(j-ycenter)^2) ;end
                if (sqrt((i-xcenter)^2+(j-ycenter)^2)>maxDist),maxDist=sqrt((i-xcenter)^2+(j-ycenter)^2) ;end
            end
       end
   end
   kip=[a b/2;b/2 c];
   [lambda1]=eig(kip);
   maxInertia=max(lambda1);
   minInertia =min(lambda1);
   roundedness=minInertia/maxInertia;
   orientation=atan(b/(a-c))/2;
end

function []=showComponent(labeled_image,label)
    imageTemp=zeros(size(labeled_image));
    imageTemp(labeled_image==label)=1;
    figure;imagesc(imageTemp);
end

function annotated_img = saveAnnotatedImg(fh)
figure(fh); 
set(fh, 'WindowStyle', 'normal');
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
annotated_img = frame.cdata;
end

