function[]=control()
    filenames=extractfield(dir(),'name');
    supportedExts=['.jpg','.png'];
    figure;
    filenames={'airplane.jpg','s3Front.jpg','s4Front.jpg'};
    for i=1:size(filenames,2)%3 because 1st and 2nd are root and parent directories
        [~,filenameTemp,ext]=fileparts(filenames{i});
        if(isempty(strfind(supportedExts,ext))==0)
           image=imread(filenames{i});
          if(i>1)
           image=image(1:8:end,1:8:end,:);
          end
%            image=imadjust(image);
           pixel_labels=segment(image);
           imagesc(pixel_labels);colorbar;
        end
    end
        
end