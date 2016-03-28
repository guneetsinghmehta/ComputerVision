%Rough
temp=rgb2hsv(image);
maxColor=max(max(temp(:,:,1)));
colors=uint8(temp(:,:,1)*255);