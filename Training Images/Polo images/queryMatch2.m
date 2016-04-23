function[queryResultFilename,distance]=queryMatch2(vectorDatabase,queryImage,number,gaborArray)
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
    patternVectorq=patternVectorFn(image,mask,gaborArray);
    boundaryCoeffsq=boundaryCoeffsFn(image,mask);
    
    siftDistance=zeros([s1,1]);
    dominantColorDistance=zeros([s1 1]);
    dominant3ColorRatioDistance=zeros([s1 1]);
    for i=1:s1
       % make it scalable with number of features
       Fs=vectorDatabase{i}.Fs;
       Ds=vectorDatabase{i}.Ds;
       dominantColors=vectorDatabase{i}.dominantColor;
       dominant3ColorRatios=vectorDatabase{i}.dominant3ColorRatio;
       patternVectors=vectorDatabase{i}.patternVector;
       boundaryCoeffss=vectorDatabase{i}.boundaryCoeffs;
       
       siftDistance(i)=sdFn(Fs,Ds,Fq,Dq);
       dominantColorDistance(i)=dcdFn(dominantColorq,dominantColors);
       dominant3ColorRatioDistance(i)=d3cpdFn(dominant3ColorRatioq,dominant3ColorRatios);
       patternDist=patternDistFn(patternVectors,patternVectorq);
       boundaryCoeffsDist=boundaryCoeffsDistFn(boundaryCoeffss,boundaryCoeffsq);
    end
    maxsiftDistance=max(siftDistance);
    siftDistance=siftDistance/maxsiftDistance;
    
    minValue=sum(w);
    index=0;
    for i=1:s1
        dist(i)=w(1)*siftDistance(i)+w(2)*dominantColorDistance(i)+w(3)*dominant3ColorRatioDistance(i);
    end
    
    %Not scalable to sort n entries
    [~,index]=sort(dist);
    for i=1:number
       queryResultFilename{i}=vectorDatabase{index(i)}.filename; 
       distance(i)=dist(index(i));
    end
    
    function[distance]=patternDistFn(pattern1,pattern2)
       distance=0; 
    end
    
    function[distance]=boundaryCoeffsDistFn(pattern1,pattern2)
       distance=0; 
    end

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
%         distance=abs(color1-color2)/numColors;
        distance=mod(abs(color1-color2),floor(numColors/2))/floor(numColors/2);% because the colors are like a circle
    end

    function[distance]=d3cpdFn(ratio1,ratio2)
       distance=abs(ratio1-ratio2); 
    end

    function[dist]=shapeDistFn(a,b)
        %input are 1Xn vector a and b
        % all inputs are assumed to be 
        dist=0;
        for k=1:size(a,2)
            dist=dist+abs(a(1,k)-b(1,k));
        end
    end
end
