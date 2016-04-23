function[]=searchGUI()
    %setup library
    if ~isequal(exist('vl_sift'), 3)
        sift_lib_dir = fullfile('sift_lib', ['mex' lower(computer)]);
        orig_path = addpath(sift_lib_dir);
        temp = onCleanup(@()path(orig_path));
    end

    %make a figure
    searchGUI=figure;
     SSize = get(0,'screensize');SW = SSize(3); SH = SSize(4);       %SW - width of screen, SH - Height of screen
    set(searchGUI,'Resize','on','Units','pixels','Position',[50 50 round(SW/10) round(SH*0.3)],'Visible','on','MenuBar','none','name','control GUI','NumberTitle','off');    
    imageFigure=figure;
    set(imageFigure,'NumberTitle','off','Menubar','none');
    
    %add two buttons - train and select query image
    train_box=uicontrol('Parent',searchGUI,'Style','Pushbutton','Units','normalized','Position',[0.05 0.75 0.9 0.2],'String','Train','Callback',@trainFn,'TooltipString','Press to train the model');
    query_box=uicontrol('Parent',searchGUI,'Style','Pushbutton','Units','normalized','Position',[0.05 0.5 0.9 0.2],'String','Load Image','Callback',@queryFn,'TooltipString','Press to search images');
    crop_box=uicontrol('Parent',searchGUI,'Style','Pushbutton','Units','normalized','Position',[0.05 0.25 0.9 0.2],'String','Crop','Callback',@cropFn);
    reset_box=uicontrol('Parent',searchGUI,'Style','Pushbutton','Units','normalized','Position',[0.05 0.0 0.9 0.2],'String','Reset','Callback',@resetFn);
    global vectorDatabase;
    global gaborArray
    %open figure, show the query image
    
    
    %show the three most similar images in figure
    
    function trainFn(~,~)
        set(train_box,'Enable','off');
        filenames={'polo3.jpg','polo2.jpg','polo1.jpg','polo4.jpg','polo5.jpg','polo6.jpeg'};
        scaleDownFactor=1;
        [vectorDatabase,gaborArray]=populateVectorDatabase(filenames,scaleDownFactor);
    end

    function queryFn(~,~)
        [filename,pathname,~]=uigetfile({'*.tif';'*.tiff';'*.jpg';'*.jpeg'},'Select query Image','MultiSelect','off'); 
        queryFilename=fullfile(pathname,filename);
        number=3;
        [closestFilenames,distance]=queryMatch2(vectorDatabase,queryFilename,number,gaborArray);
        display(closestFilenames);
        figure(imageFigure);
        subplot(1,number+1,1);imshow(imread(queryFilename));title('query Image');
        for i=1:number
            subplot(1,number+1,i+1);imshow(imread(closestFilenames{i}));title(['result Image' num2str(i) ' distance=' num2str(distance(i))]);
        end
    end

    function resetFn(~,~)
        clf (imageFigure);
        searchGUI();
    end

    function cropFn(~,~)
        figure(imageFigure);
        tempFig=figure;
        [filename,pathname,~]=uigetfile({'*.jpg';'*.tiff';'*.tif';'*.jpeg'},'Select query Image','MultiSelect','off');
        queryFilename=fullfile(pathname,filename);
        image=imread(queryFilename);
        imshow(image);
        h=imrect;
        roi=getPosition(h);
        
        data2=roi;
        a=data2(1);b=data2(2);c=data2(3);d=data2(4);
        vertices(:,:)=[a,b;a+c,b;a+c,b+d;a,b+d;];
        BW=roipoly(image,vertices(:,1),vertices(:,2));
        B=bwboundaries(BW);
        boundary=B{1};
        xindices=boundary(:,1);xMin=min(xindices);xMax=max(xindices);
        yindices=boundary(:,2);yMin=min(yindices);yMax=max(yindices);
        
        BW=repmat(uint8(BW),[1 1 3]);
        croppedImage=image.*BW;
        croppedImage=croppedImage(xMin:xMax,yMin:yMax,:);
        
        tempFig2=figure;
        imshow(croppedImage);
        imwrite(croppedImage,'cropped.tif');
        close(tempFig);
        close(tempFig2);
        
        queryFilename='cropped.tif';
        number=3;
        [closestFilenames,distance]=queryMatch2(vectorDatabase,queryFilename,number);
        display(closestFilenames);
        figure(imageFigure);
        subplot(1,number+1,1);imshow(imread(queryFilename));title('query Image');
        for i=1:number
            subplot(1,number+1,i+1);imshow(imread(closestFilenames{i}));title(['result Image' num2str(i) ' distance=' num2str(distance(i))]);
        end
    end
end