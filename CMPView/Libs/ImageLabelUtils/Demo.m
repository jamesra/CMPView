function Demo( ImageName, minThresh, maxThresh )
%DEMO Helper function to display an image and run all routines for
%assingment

    I = imread(ImageName);
    imshow(I); 
    
    H = histogram(I); 
    
    hHistFig = figure; 
    hAxes = axes; 
    Bar(hAxes, H);
    set(hAxes, 'XLim', [0 255]); 
    set(hAxes, 'YLim', [0 max(H)]);
    
    hImageFig = figure; 
    
    M = threshold(I, minThresh,maxThresh);
    [L, maxLabel, LabelMap] = label(M); 
   
    cmap = rand(length(unique(L)),3);
    imshow(L,cmap); 
    
    
    D = Denoise(L, 10); 
    
    hDenoiseFig = figure;
    imshow(D,cmap); 
    
    LabelMap = GetLabelMap(D);
    disp(LabelMap); 
end

