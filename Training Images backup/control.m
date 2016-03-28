function[]=control()
    filenames=extractfield(dir(),'name');
    supportedExts=['.jpg','.png'];
    figure;
    for i=3:size(filenames,2)%3 because 1st and 2nd are root and parent directories
        [~,filenameTemp,ext]=fileparts(filenames{i});
        if(isempty(strfind(supportedExts,ext))==0)
           image=imread(filenames{i});
           image=image(1:8:end,1:8:end,:);
%            image=imadjust(image);
           pixel_labels=segment(image);
           imagesc(pixel_labels);colorbar;
        end
    end
        
end