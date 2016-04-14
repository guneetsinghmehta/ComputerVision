function[]=trash2()
    n=10;
    y=0:3:18;
    x=1:size(y,2);
    x2=indices(y,n)
    xinterp=interp1(x,y,x2,'linear')
end

function[x2]=indices(x,n)
     s1=size(x,2);s2=n-s1;
     x2=zeros([1,s2]);
    for i=1:s2
       x2(i)=i*s1/s2;
    end
end
