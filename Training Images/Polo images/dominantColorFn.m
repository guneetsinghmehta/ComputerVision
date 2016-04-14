  function[dominantColor,dominant3ColorRatio]=dominantColorFn(image,mask)
        %input - image of shirt,mask - region where shirt is present
        %output - dominantColor -most dominant color (except black)
        %       -dominant3ColorPercent - percent contribution of top three
        %       colors(excluding black)
        %caveat - the color of white is a bunch of random colors
        %see the colormap by  figure;imagesc(hue);colormap hsv;colorbar;
        %caveat2 - disregards the darkness and lightness of color
        
        temp=rgb2hsv(image);
        hue=uint8(temp(:,:,1)*255);%255 discretecolors
        h=imhist(hue);%find color only in the mask region
        [hsorted,index]=sort(h,'descend');
        dominantColor=index(1);
       %  figure;plot(1:256,h);
        if(dominantColor==1)
           %due to black background. Choose the next color
           dominantColor=index(2);
        end
        
        colorNum=0;dominant3ColorRatio=0;
        for i=1:4
            if(index(i)==1)
               continue; 
            else
                if(colorNum==3),break;end%if top four colors are non black then leave the third color
                dominant3ColorRatio=dominant3ColorRatio+hsorted(i);
                colorNum=colorNum+1;
            end
        end
        [s1,s2,~]=size(mask);
        maskTemp=uint8(mask(:,:,1));
        forgroundPixels=sum(maskTemp(:));
        dominant3ColorRatio=dominant3ColorRatio/(forgroundPixels);
        
    end