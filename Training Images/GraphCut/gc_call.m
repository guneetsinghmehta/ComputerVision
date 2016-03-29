function[returnMask]= gc_call(image)
im = im2double(image);
sz = size(im);
% segment the image into 2 different regions
k = 4;

distance = 'sqEuclidean';
% cluster the image colors into 2 regions
data = ToVector(im);
[idx cTemp] = kmeans(data, k, 'distance', distance,'maxiter',200);

%Rectangle method
f1=figure;imshow(image);
h=imrect;
roi=getPosition(h);
a=roi(1);b=roi(2);c=roi(3);d=roi(4);
vertices(:,:)=[a,b;a+c,b;a+c,b+d;a,b+d;];
mask=roipoly(image,vertices(:,1),vertices(:,2));
[s1,s2]=size(mask);
idx3=reshape(mask,[s1*s2 1]);
idx3=double(idx3)+1;
close(f1);

% calculate the data cost per cluster center
c=cTemp;
Dc = zeros([sz(1:2) k],'single');
for ci=1:k
    % use covariance matrix per cluster
    icv = inv(cov(data(idx==ci,:)));    
    dif = data - repmat(c(ci,:), [size(data,1) 1]);
    % data cost is minus log likelihood of the pixel to belong to each
    % cluster according to its RGB value
    Dc(:,:,ci) = reshape(sum((dif*icv).*dif./2,2),sz(1:2));
end

% cut the graph

% smoothness term: 
% constant part
Sc = ones(k) - eye(k);
% spatialy varying part
% [Hc Vc] = gradient(imfilter(rgb2gray(im),fspecial('gauss',[3 3]),'symmetric'));
[Hc Vc] = SpatialCues(im);

gch = GraphCut('open', Dc, 10*Sc, exp(-Vc*5), exp(-Hc*5));
gch = GraphCut('set',gch,idx3);%L returns the mask
[gch L] = GraphCut('get', gch);
gch = GraphCut('close', gch);

% show results
imshow(im);
hold on;
returnMask=logical(L);




%---------------- Aux Functions ----------------%
function v = ToVector(im)
% takes MxNx3 picture and returns (MN)x3 vector
sz = size(im);
v = reshape(im, [prod(sz(1:2)) 3]);

%-----------------------------------------------%
function ih = PlotLabels(L)

L = single(L);

bL = imdilate( abs( imfilter(L, fspecial('log'), 'symmetric') ) > 0.1, strel('disk', 1));
LL = zeros(size(L),class(L));
LL(bL) = L(bL);
Am = zeros(size(L));
Am(bL) = .5;
ih = imagesc(LL); 
set(ih, 'AlphaData', Am);
colorbar;
colormap 'jet';

%-----------------------------------------------%
function [hC vC] = SpatialCues(im)
g = fspecial('gauss', [13 13], sqrt(13));
dy = fspecial('sobel');
vf = conv2(g, dy, 'valid');
sz = size(im);

vC = zeros(sz(1:2));
hC = vC;

for b=1:size(im,3)
    vC = max(vC, abs(imfilter(im(:,:,b), vf, 'symmetric')));
    hC = max(hC, abs(imfilter(im(:,:,b), vf', 'symmetric')));
end