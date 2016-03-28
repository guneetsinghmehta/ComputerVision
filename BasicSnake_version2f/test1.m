I = imread('testimage.png');
 % Convert the image to double data type
  I = im2double(I); 
 % Show the image and select some points with the mouse (at least 4)
 %figure, imshow(I); [y,x] = getpts;
  y=[182 233 251 205 169];
  x=[163 166 207 248 210];
 % Make an array with the clicked coordinates
  P=[x(:) y(:)];
 % Start Snake Process
  Options=struct;
  Options.Verbose=true;
  Options.Iterations=5000;
  Options.Delta=-0.2;
  Options.Alpha=0.00001;%Less elasticity
  [O,J]=Snake2D(I,P,Options);
 % Show the result
  Irgb(:,:,1)=I;
  Irgb(:,:,2)=I;
  Irgb(:,:,3)=J;
  figure, imshow(Irgb,[]); 
  hold on; plot([O(:,2);O(1,2)],[O(:,1);O(1,1)]);