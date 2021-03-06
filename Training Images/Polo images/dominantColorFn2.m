  function[dominantColor,dominant3ColorRatio,colorInfo]=dominantColorFn2(image,mask)
        %input - image of shirt,mask - region where shirt is present
        %output - dominantColor -most dominant color (except black)
        %       -dominant3ColorPercent - percent contribution of top three
        %       colors(excluding black)
        %       - colors - primary(>45%),secondary(10< <45%) and decorative
        %       colors (2< <10%)
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
        foregroundPixels=sum(maskTemp(:));
        dominant3ColorRatio=dominant3ColorRatio/(foregroundPixels);
        
        %Using hsorted ,index and forgroudPixels to find the primary
        %,secondary and tertiary colors
       
        primary={};secondary={};
        decorative={};
        for i=1:255
            if(index(i)==1),continue;end
           if(hsorted(i)<0.02*foregroundPixels)
              break; 
           else
               if(hsorted(i)>0.45*foregroundPixels)
                  primary{end+1}=index(i); 
               elseif(hsorted(i)>0.10*foregroundPixels)
                   secondary{end+1}=index(i);
               elseif(hsorted(i)>0.02*foregroundPixels)
                    decorative{end+1}=index(i);
               end
           end
        end
        colorInfo.primary=primary;
        colorInfo.secondary=secondary;
        colorInfo.decorative=decorative;
    end