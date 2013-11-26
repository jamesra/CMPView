function varargout = CMPView(varargin)
% CMPView M-file for CMPView.fig
%      CMPView, by itself, creates a new CMPView or raises the existing
%      singleton*.
%
%      H = CMPView returns the handle to a new CMPView or the handle to
%      the existing singleton*.
%
%      CMPView('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CMPView.M with the given input arguments.
%
%      CMPView('Property','Value',...) creates a new CMPView or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CMPView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CMPView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CMPView

% Last Modified by GUIDE v2.5 14-Sep-2011 16:20:47
warning on MATLAB:divideByZero

dbstop if error

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CMPView_OpeningFcn, ...
                   'gui_OutputFcn',  @CMPView_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CMPView is made visible.
function CMPView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CMPView (see VARARGIN)

%if(matlabpool('size') == 0)
try
    matlabpool;
catch
    disp('Exception starting matlabpool')
end
%end
        
%Make sure our lib directory is in the path
%We expect CMPView to be run from the CMPView directory
[workingDir,mfile, ext] = fileparts(which(mfilename));
libDir = fullfile(workingDir, 'libs'); 
libDirs = genpath(libDir);
path(libDirs, path); 

% Choose default command line output for CMPView
handles.output = hObject;

handles.ProbeMap = ProbeMap('ProbeName.xls'); 
handles.ParentFigure = hObject; 

handles.Controller = Controller(hObject);
handles.Controller.Categorizers = LoadCategorizers(handles.Controller, handles.menuCategorizers);
handles.Controller.ImageFilters = LoadCategoryFilters(handles.Controller, handles.menuImageFilters); 

guidata(hObject,handles); 

%Create a panel for the AttributeView
hPanel = uipanel('units', 'normalized', ...
                 'parent', hObject,...
                 'position', [0 0 1 1]); 
             
handles.CollectionView = CollectionView(handles.Controller, hPanel);
          
%Create the view windows
handles.Views = LoadViews(handles.Controller, handles.menuViews); %Returns an array of View handles

%Load the actions
handles.Controller.Actions = LoadActions(); 

%Update handles structure
guidata(hObject, handles);

% UIWAIT makes CMPView wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = CMPView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFile_LoadImageSet_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile_LoadImageSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    defaultDataPath = getpref('CMPView', 'DataPath', []);
    directory_name = uigetdir(defaultDataPath, 'Select the directory containing images to cluster'); 
    
    % uigetdir returns a string if the user chose a directory and the number 0 if
    % they did not
    if(~ischar(directory_name))
        return;
    end
    
    setpref('CMPView', 'DataPath', directory_name);

    images = []; 
    
    %Get a list of all valid formats
    formats = imformats;

    files = dir(directory_name); 
    
    handles.ImagesPath = directory_name; 
    
    maskfound = false; 
    listofnames = {};
    
    
    tempListNames = cell(1,length(files)); 
    ProcessedImages = cell(1,length(files)); 

    parfor iFile = 1:length(files)
        name = lower(files(iFile).name);
        if(strcmp(name, '.') || strcmp(name, '..'))
            continue; 
        end 

        fullname = fullfile(directory_name, name);     
        [p, listname, ext] = fileparts(fullname); 
        
        %Macs create files with . before the name, these should be ignored
        if(listname(1) == '.')
            continue; 
        end
        
        tempListNames{iFile} = listname; 
        
        %Determine if file is an image
        ext = lower(ext);
        %Trim the leading '.' from the extension
        if(length(ext) > 1)
            ext(1) = []; 
        end
        
        bFormatFound = false; 
        for(iFormat = 1:length(formats))
            extensions = formats(iFormat).ext;
            for(iExt = 1:length(extensions))
                if(strcmpi(extensions{iExt}, ext))
                    bFormatFound = true;
                    break;
                end
            end
            
            if(bFormatFound)
                break;
            end
        end
        
        %Skip this file if it is not an image
        if(~bFormatFound)
            continue;
        end
                
        newImage = imread(fullname);
        info = imfinfo(fullname);
        
        if(strcmp(info.ColorType, 'truecolor'))
            newImage = rgb2gray(newImage);
            if(info.BitDepth == 24 || info.BitDepth == 32)
                info.BitDepth = 8; 
            end    
        elseif(strcmp(info.ColorType, 'indexed'))
            newImage = ind2gray(newImage);
        end
        
        if(~isempty(strfind(name, 'mask')))
            %Threshhold image to ensure it is black and white
            if(~islogical(newImage))
                level = graythresh(newImage);
                BW = im2bw(newImage, level);
            else
                BW = newImage;
            end
%            handles.AttributeView = set(handles.AttributeView, 'Mask', BW);
            maskfound = true; 
        else
            %Scale the image to go from 0 to 1
            newImage = single(newImage) ./ ((2^info.BitDepth) - 1);
            ProcessedImages{iFile} = newImage; 
            
        end
    end
    
    BlobImages = cell(1,length(files));
    YDim = 0; 
    XDim = 0;
    nImages = 0;
    parfor(iFile = 1:length(files))
        if(~isempty(ProcessedImages{iFile}))
           [YDim, XDim] = size(ProcessedImages{iFile});
           BlobImages{iFile} = ImBlob(ProcessedImages{iFile}, 3); 
           nImages = nImages + 1; 
        end
    end
    
    BlobImages = cat(3,BlobImages{:});
    
    MaxBlobImages = max(BlobImages, [], 3);
    
    MaxBlobImages = MaxBlobImages - min(min(MaxBlobImages)); 
    
    MaxBlobImages = MaxBlobImages ./ max(max(MaxBlobImages)); 
    
    images = cat(3, images, MaxBlobImages);
    listofnames{end + 1} = 'Blob'; 
    
    for iFile = 1:length(files)
        
        if(~isempty(ProcessedImages{iFile}))
             
            images = cat(3, images, ProcessedImages{iFile});
 %           images = cat(3, images, BlobImages(:,:,iFile));
            
            listname = tempListNames{iFile}; 
            %Determine the name for the probe if we can
            indicies = strfind(listname, '_');
            
            if(isempty(indicies))
               listofnames{end + 1} = listname; 
 %              listofnames{end + 1} = ['blob_' listname];
            else
               probecode = listname((indicies(end)+1):end);
               probename = MapCode(handles.ProbeMap, probecode);
               if(isempty(probename))
                   listofnames{end + 1} = listname;
 %                  listofnames{end + 1} = ['blob_' listname];
               else
                   listofnames{end + 1} = probename; 
 %                  listofnames{end + 1} = ['blob ' probename];
               end
            end
            
        end
    end
    
    
    
    collection = Collections.PixelDataCollection(handles.Controller, images, listofnames);
    collection.Name = directory_name;
    handles.Controller.AddCollection(collection); 
    
    handles.Controller.ProbeNames = listofnames;
    
    guidata(gcf, handles);

%Search the views package and load one instance of every view class
%The controller argument is used in the eval function, ignore Matlab
%warning;
function hViews = LoadViews(controller, menu)
    hViews = {}; 

    % This should work, but the Mathworks didn't implement meta.package
    % correctly
    
    mpkg = meta.package.fromName('Views');
    for k=1:length(mpkg.Classes)
        %Create an instance of all classes which derive from Viewer
        supers = mpkg.Classes{k}.SuperClasses;
        for(s = 1:length(supers))
            if(strcmpi(supers{s}.Name, 'Viewer'))
                disp(strcat('Creating Viewer: ', mpkg.Classes{k}.Name));
                
                ViewObj = eval(strcat(mpkg.Classes{k}.Name,'(controller);'));
                hViews{end+1} = ViewObj; 
                
                %Create a menu item for the view object
                hViewMenu = uimenu(menu, 'Label', ViewObj.Name, ...
                                   'Checked', get(ViewObj.Figure, 'Visible'), ...
                                   'Callback', @ViewCallback, ...
                                   'UserData', ViewObj);
                break;
            end
        end
    end
   
    
    %{
    files = dir('+Views');
    for(iFile = 1:length(files))
%       disp(files(iFile));
       [path, name, ext] = fileparts(files(iFile).name);
       if(strcmpi(ext, '.m'))
           mclass = eval(strcat('?Views.', name));
           
           supers = mclass.SuperClasses;
           for(s = 1:length(supers))
               if(strcmpi(supers{s}.Name, 'Viewer'))
                   disp(strcat('Creating Viewer: ', mclass.Name));
                   
                   ViewObj = eval(strcat(mclass.Name,'(controller);'));
                   hViews{end+1} = ViewObj; 

                   
                   %Create a menu item for the view object
                   hViewMenu = uimenu(menu, 'Label', ViewObj.Name, ...
                                       'Checked', get(ViewObj.Figure, 'Visible'), ...
                                       'Callback', @ViewCallback, ...
                                       'UserData', ViewObj);
                   break;
               end
           end
       end
    end
    %}
    
    disp(''); 
    

% --------------------------------------------------------------------
function menuViews_Callback(hObject, eventdata, handles)
% hObject    handle to menuViews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %Build a sub-menu containing the status of all the views
    childMenus = get(hObject, 'Children'); 

    for(iMenu = 1:length(childMenus))
       obj = get(childMenus(iMenu), 'UserData');
       set(childMenus(iMenu), 'Checked', get(obj.Figure,'Visible'));
    end


function ViewCallback(hObject, src, event)
    
    obj = get(hObject, 'UserData');
    obj.Visible = ~obj.Visible; 
    
%Search the views package and load one instance of every view class
%The controller argument is used in the eval function, ignore Matlab
%warning;
function hCategorizers = LoadCategorizers(controller, menu)
    hCategorizers = {}; 

    disp('LoadCategorizers:');
    
    mpkg = meta.package.fromName('Categorizers');
    for k=1:length(mpkg.Classes)
        %Create an instance of all classes which derive from Viewer
        supers = mpkg.Classes{k}.SuperClasses;
        for(s = 1:length(supers))
            if(strcmpi(supers{s}.Name, 'Categorizer'))
                disp(strcat('Creating Categorizer: ', mpkg.Classes{k}.Name));
                
                CategorizerObj = eval(strcat(mpkg.Classes{k}.Name,'(controller);'));
                hCategorizers{end + 1} = CategorizerObj; 
                
                %Create a menu item for the categorizer object
                hCategorizerMenu = uimenu(menu, 'Label', CategorizerObj.Name, ...
                                       'Callback', @CategorizerCallback, ...
                                       'UserData', CategorizerObj);
                break;
            end
        end
    end
    
    %Search the views package and load one instance of every view class
%The controller argument is used in the eval function, ignore Matlab
%warning;
function hImageFilters = LoadCategoryFilters(controller, menu)
    hImageFilters = {}; 

    disp('Load Category Filters:');
    
    mpkg = meta.package.fromName('CategoryFilters');
    for k=1:length(mpkg.Classes)
        %Create an instance of all classes which derive from Viewer
        supers = mpkg.Classes{k}.SuperClasses;
        for(s = 1:length(supers))
            if(strcmpi(supers{s}.Name, 'CategoryFilterBase'))
                disp(strcat('Creating Category Filter: ', mpkg.Classes{k}.Name));
                
                FilterObj = eval(strcat(mpkg.Classes{k}.Name,'(controller);'));
                hImageFilters{end + 1} = FilterObj; 
                
                %Create a menu item for the categorizer object
                hImageFilterMenu = uimenu(menu, 'Label', FilterObj.Name);
                                   
                hImageFilterExecuteMenu = uimenu(hImageFilterMenu, 'Label', 'Execute', ...
                                       'Callback', @ImageFilterExecuteCallback, ...
                                       'UserData', FilterObj);
                
                %Create a menu item for the categorizer object
                hImageFilterPropertiesMenu = uimenu(hImageFilterMenu, 'Label', 'Properties', ...
                                       'Callback', @ImageFilterPropertyCallback, ...
                                       'UserData', FilterObj);
                break;
            end
        end
    end
   
    
    %{
    files = dir('+Categorizers');
    for(iFile = 1:length(files))
       
       [path, name, ext] = fileparts(files(iFile).name);
       if(strcmpi(ext, '.m'))
           disp(['    ' files(iFile).name]);
           try
               mclass = eval(strcat('?Categorizers.', name));
           catch
               %Skip the class if it doesn't have meta-data
               continue; 
           end
           
           supers = mclass.SuperClasses;
           for(s = 1:length(supers))
               if(strcmpi(supers{s}.Name, 'Categorizer'))
                   disp(strcat('Creating Categorizer: ', mclass.Name));
                   CategorizerObj = eval(strcat(mclass.Name,'(controller);'));
                   hCategorizers{end + 1} = CategorizerObj; 
                   
                   %Create a menu item for the view object
                   hCategorizerMenu = uimenu(menu, 'Label', CategorizerObj.Name, ...
                                       'Callback', @CategorizerCallback, ...
                                       'UserData', CategorizerObj);
                   break;
               end
           end
       end
    end
    %}
    
    disp(''); 
    
%Search the actions package for a list of actions
function listActionClasses = LoadActions(controller)
    listActionClasses = {}; 

    disp('listActionClasses');
    
    mpkg = meta.package.fromName('Actions');
    for k=1:length(mpkg.Classes)
        %Create an instance of all classes which derive from Viewer
        supers = mpkg.Classes{k}.SuperClasses;
        for(s = 1:length(supers))
            if(strcmpi(supers{s}.Name, 'MenuAction'))
                disp(strcat('Found Menu Action: : ', mpkg.Classes{k}.Name));
                
  %              MenuAction = eval(strcat(mpkg.Classes{k}.Name,'();'));
                
                listActionClasses{end+1} = mpkg.Classes{k}.Name;
                break;
            end
        end
    end
    
    %{
    files = dir('+Actions');
    for(iFile = 1:length(files))
       
       [path, name, ext] = fileparts(files(iFile).name);
       if(strcmpi(ext, '.m'))
           disp(['    ' files(iFile).name]);
           try
               mclass = eval(strcat('?Actions.', name));
           catch
               %Skip the class if it doesn't have meta-data
               continue; 
           end
           
           supers = mclass.SuperClasses;
           for(s = 1:length(supers))
               if(strcmpi(supers{s}.Name, 'MenuAction'))
                   disp(strcat('Found New Menu Action: ', mclass.Name));
                   
                   listActionClasses{end+1} = mclass.Name;  
                   break;
               end
           end
       end
    end
    
    %}
    
    disp(''); 
    
function CategorizerCallback(hObject, src, event)
    obj = get(hObject, 'UserData');
    obj.ShowProperties();
    
function ImageFilterPropertyCallback(hObject, src, event)
    obj = get(hObject, 'UserData');
    obj.ShowProperties();
    
function ImageFilterExecuteCallback(hObject, src, event)
    obj = get(hObject, 'UserData');
    
    handles = guidata(gcf);
    
    handles.Controller = handles.Controller.Filter(obj); 
    
    guidata(gcf, handles);


% --- Executes when user attempts to close figure1.
function CMPView_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure

    if(~isempty(handles))

        %Close all view figures
        for(iView = 1:length(handles.Views))
           delete(handles.Views{iView});  
        end

        handles.Views = []; 
    end

    delete(hObject);


% Load a collection from the disk
% --------------------------------------------------------------------
function menuFile_LoadCollection_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile_LoadCollection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 [FileName, PathName] = uigetfile('*.CMPCollection', ...
                      'Select the directory containing images to cluster', ...
                      [handles.Controller.DataPath]);
                  
% uigetfile returns a string if the user chose a file and the number 0 if
% they did not
 if(~ischar(FileName))
     return; 
 end

 collection = load([PathName filesep FileName], '-mat');
  
 handles.Controller.AddCollection(collection.collection);
 
%Save current collection to the disk
% --------------------------------------------------------------------
function menuFile_SaveCollection_Callback(hObject, eventdata, handles)
    % hObject    handle to menuFile_SaveCollection (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

     defaultDataPath = getpref('CMPView', 'DataPath', []);
     [FileName, PathName] = uiputfile('*.CMPCollection', 'Choose where to save the current collection', ...
                                [defaultDataPath filesep handles.Controller.CurrentCollection.Name]); 

    % uiputfile returns a string if the user chose a file and the number 0 if
    % they did not
     if(~ischar(FileName))
         return;
     end
     
     setpref('CMPView', 'DataPath', defaultDataPath);

     %CurrentCollection is a dependent property and 'save' can't call it to
     %save the data, so I pull it out ahead of saving
     collection = handles.Controller.CurrentCollection; 

        save([PathName filesep FileName], 'collection');

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to menuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuEditUndo_Callback(hObject, eventdata, handles)
% hObject    handle to menuEditUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.Controller.Undo();

% --------------------------------------------------------------------
function menuEditRedo_Callback(hObject, eventdata, handles)
% hObject    handle to menuEditRedo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.Controller.Redo();


% --------------------------------------------------------------------
function menuImageFilters_Callback(hObject, eventdata, handles)
% hObject    handle to menuImageFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuCategorizers_Callback(hObject, eventdata, handles)
% hObject    handle to menuCategorizers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
