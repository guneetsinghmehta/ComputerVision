function[queryMatchResult]=queryMatch(vectorDatabase,queryImage)
%features right now - sift,dominantColor,dominant3ColorRatio
% weights               1 ,     10      ,   5
% calculate distances of each feature, for sift ? 
% calculate finalValue 1*siftDist+10*domColorDist+5*....
% output - filenames of image with minimum finalValue
    s1=size(vectorDatabase,1);
    w=[1,10,5];
    
    image=imread(queryImage);
    mask=getMask(image);
    image=image.*uint8(mask);
    
    %finding features for the query image
    gray_s=rgb2gray(im2single(image));
    [Fq, Dq] = vl_sift(gray_s);
    [dominantColorq,dominant3ColorRatioq]=dominantColorFn(image,mask);
    
    siftDistance=zeros([s1,1]);
    dominantColorDistance=zeros([s1 1]);
    dominant3ColorRatioDistance=zeros([s1 1]);
    for i=1:s1
       % make it scalable with number of features
       Fs=vectorDatabase{i}.Fs;
       Ds=vectorDatabase{i}.Ds;
       dominantColors=vectorDatabase{i}.dominantColor;
       dominant3ColorRatios=vectorDatabase{i}.dominant3ColorRatio;
       
       siftDistance(i)=sdFn(Fs,Ds,Fq,Dq);
       dominantColorDistance(i)=dcdFn(dominantColorq,dominantColors);
       dominant3ColorRatioDistance(i)=d3cpdFn(dominant3ColorRatioq,dominant3ColorRatios);
    end
    maxsiftDistance=max(siftDistance);
    siftDistance=siftDistance/maxsiftDistance;
    
    minValue=sum(w);
    index=0;
    for i=1:s1
        temp=w(1)*siftDistance(i)+w(2)*dominantColorDistance(i)+w(3)*dominant3ColorRatioDistance(i);
        if(temp<minValue)
           index=i;
           minValue=temp;
        end
    end
    display(minValue);
    queryMatchResult=vectorDatabase{index}.filename;
    
    function[distance]=sdFn(Fs,Ds,Fq,Dq)
        [matches, scores] = vl_ubcmatch(Ds, Dq);
        scores=sort(scores);
        if(size(scores,2)>=10)
            distance=mean(scores(1:10));
        else
            distance=mean(scores);
        end
            
    end

    function[distance]=dcdFn(color1,color2)
        %255 possible colors thus return the distance as
        numColors=255;
        distance=abs(color1-color2)/numColors;
    end

    function[distance]=d3cpdFn(ratio1,ratio2)
       distance=abs(ratio1-ratio2); 
    end
end
