function[]=control()
    filenames=extractfield(dir(),'name');
    supportedExts=['.jpg','.png'];
    f1=figure;
    for i=3:size(filenames,2)%3 because 1st and 2nd are root and parent directories
        [~,filenameTemp,ext]=fileparts(filenames{i});
        if(isempty(strfind(supportedExts,ext))==0)
           image=imread(filenames{i});
          if(i>3)
           image=image(1:8:end,1:8:end,:);
          end
           pixel_labels=gc_call(image);
           figure(f1);imagesc(pixel_labels);colorbar;
        end
    end
        
end