function[]=trash3()
    files={'shirt1.jpg','shirt2.jpg','trouser1.jpg','trouser2.jpg','polo1.jpg','polo2.jpg'};
%     files={'trouser1.jpg','trouser2.jpg'};
    f1=figure;
    for i=1:size(files,2)
        image=imread(files{1,i});
        mask=getMask(image);
        Zfft(i,:)=boundaryCoeffsFn(image,mask);
        figure(f1);
        ax1=subplot(1,2,1);imshow(image);
        ax2=subplot(1,2,2);imagesc(mask);
        linkaxes([ax1,ax2]);
    end
    for i=1:size(files,2)
        for j=1:size(files,2)
           dist=findDist(Zfft,i,j);
           fprintf('dist =%f i=%d j=%d\n',dist,i,j);
        end 
        fprintf('\n');
    end
end

function[dist]=findDist(Zfft,a,b)
    dist=0;
    for i=1:size(Zfft(1,:),2)
        dist=dist+abs(Zfft(a,i)-Zfft(b,i));
    end
end