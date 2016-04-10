%tutorial on SIFT matching - VLFEAT - http://www.vlfeat.org/overview/sift.html
if ~isequal(exist('vl_sift'), 3)
    sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
    orig_path = addpath(sift_lib_dir);
    temp = onCleanup(@()path(orig_path));
end

I=imread('s3Front.jpg');
I=I(1:8:end,1:8:end,:);
[f1,d1]=vl_sift(single(rgb2gray(I)));
Itemp=imrotate(I,10);
[f2,d2]=vl_sift(single(rgb2gray(Itemp)));
f=f1;
d=d1;
perm = randperm(size(f,2)) ;
sel = perm(1:50) ;
figure;imshow(I);
h1 = vl_plotframe(f(:,sel)) ;
h2 = vl_plotframe(f(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
set(h3,'color','g') ;

[matches,scores]=vl_ubcmatch(d1,d2);
fig1=figure;imshow(I);hold on;
fig2=figure;imshow(Itemp);hold on;
for i=1:size(matches,2)
   if(scores(1,i)<8000)
       index1=matches(1,i);
       index2=matches(2,i);
       figure(fig1);
       x1=f1(1,index1);y1=f1(2,index1);
       text(x1,y1,'*','color',[0 1 0]);
       figure(fig2);
       x2=f2(1,index2);y2=f2(2,index2);
       text(x2,y2,'*','color',[0 1 0]);
       pause(1);
   end
end