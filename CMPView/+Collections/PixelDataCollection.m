classdef PixelDataCollection < DataCollection
%PIXELDATACOLLECTION Summary of this class goes here
%   Detailed explanation goes here

   properties
       PCAScores = []; %Principle Component Analysis Coefficients
       ImageSize = [];
       PrinCompCategories = []; %Categories used to generate PCA analysis
       PCAAttributes = []; %Attributes used to generate PCA analysis
       RGBAttributes = [1 2 3];
   end

   methods (Static = true)
       function obj = loadobj(obj)
%          obj = PixelDataCollection(); 
         obj = DataCollection.loadobj(obj); 
       end
   end
   
   methods
       function obj = PixelDataCollection(Controller, Images, Names)
           obj = obj@DataCollection(Controller, Images,Names);      
           obj.ImageSize = size(Images);
           
           if(obj.NumAttributes < 3)
               if(obj.NumAttributes == 2)
                  obj.RGBAttributes = [1 2 1]; 
               else
                  obj.RGBAttributes = [1 1 1]; 
               end
           end
       end
       
       %Each collection provides a list of views.  
       function Strings = ImageStrings(obj) %Description of images returned by Image
           Strings = {'Classified Image', 'PCA', 'Color Image (Not Implemented)'};
           
           for(iAttribute = 1:length(obj.AttributeNames))
                Strings{iAttribute+3} = obj.AttributeNames{iAttribute}; 
                if(obj.RGBAttributes(1) == iAttribute)
                   Strings{iAttribute+3} = [Strings{iAttribute+3} ' [R]'];
                end
                
                if(obj.RGBAttributes(2) == iAttribute)
                   Strings{iAttribute+3} = [Strings{iAttribute+3} ' [G]'];
                end
                
                if(obj.RGBAttributes(3) == iAttribute)
                   Strings{iAttribute+3} = [Strings{iAttribute+3} ' [B]'];
                end
           end        
       end
       
       %An image where each pixel is assigned a number according to class
       %membership
       function img = CategoryIndexImage(obj)
           img = reshape(obj.Categories, obj.ImageSize(1), obj.ImageSize(2)); 
       end
       
       %Return a matrix representing the specified dimension that can be
       %resized to the original data size
       function img = Image(obj,idx)
           %Check if we are loading a special image such as classified,
           %color, or mask
           
           if(idx <=3 ) 
               if(idx == 1) %Create clustered image
                  %Load the color of each category
                  cmap = [obj.CategoryObjects.StatusColor];
                  cmap = reshape(cmap, 3, length(obj.CategoryObjects))'; %Yes, the apostrophe is required
        
                  %Map each pixel's category index to a color from the map
                  img = cmap(obj.Categories, :);
                  img = reshape(img, obj.ImageSize(1), obj.ImageSize(2),3);
               elseif(idx == 2) % Create principle component analysis RGB image
                  iRows = []; %Rows to be execute PCA on
                  PCACategories = []; 
                  
                  %Figure out which classes are unlocked
                  if(isempty(obj.CategoryObjects))
                     %There are no categories so use the entire image as input 
                     [numRows, ~] = size(obj.Attributes);
                     iRows = 1:numRows; 
                  else
                      %Identify the unlocked categories
                      for(iCat = 1:length(obj.CategoryObjects))
                        if(obj.CategoryObjects(iCat).CanRemoveMembers)
                            iRows = cat(1, iRows, obj.CategoryObjects(iCat).Members);
                            PCACategories = cat(1,PCACategories,iCat); 
                        end
                      end
                  end
                     
                  if(isempty(obj.PrinCompCategories) || ...
                          ~isequal(PCACategories, obj.PrinCompCategories) || ...
                          ~isequal(obj.PCAAttributes, obj.AttributesEnabled))
                     obj.PrinCompCategories = PCACategories;
                     obj.PCAAttributes = obj.AttributesEnabled;
                     [PCACoeffs, Scores, Latent] = pca(obj.Attributes(iRows,obj.AttributesEnabled));
                     
                     nAttributes = sum(obj.AttributesEnabled);
                     
                     [numPixels, ~]= size(obj.Attributes);
                     
                     if(nAttributes < 3)
                         Temp = zeros(length(iRows), 3);
                         Temp(:,1:nAttributes) = Scores;
                         Scores = Temp; 
                     else

                         %Trim the extra dimensions from Scores
                         Scores = Scores(:,1:3);
                     end

                     %Normalize Scores to range of 0-255
                     Mins = min(Scores);
                     Maxs = max(Scores); 
                     Scalar = 1 ./ (Maxs - Mins);
                     Scores(:,1) = (Scores(:,1) - Mins(1)) * Scalar(1);
                     Scores(:,2) = (Scores(:,2) - Mins(2)) * Scalar(2);
                     Scores(:,3) = (Scores(:,3) - Mins(3)) * Scalar(3);

                     %Create an image with a black background and populate
                     %it with scores
                     PCAImage = zeros(numPixels, 3); 
                     PCAImage(iRows,:) = Scores;
                     obj.PCAScores = PCAImage; 
                  end
                  
                  img = reshape(obj.PCAScores, obj.ImageSize(1), obj.ImageSize(2), 3); 
                 
               elseif(idx == 3)
                  img = zeros(obj.ImageSize(1), obj.ImageSize(2)); 

                  img(:,:, 1) = reshape(obj.Attributes(:, obj.RGBAttributes(1)), obj.ImageSize(1), obj.ImageSize(2));
                  img(:,:, 2) = reshape(obj.Attributes(:, obj.RGBAttributes(2)), obj.ImageSize(1), obj.ImageSize(2));
                  img(:,:, 3) = reshape(obj.Attributes(:, obj.RGBAttributes(3)), obj.ImageSize(1), obj.ImageSize(2));
               end
               
              
           else
                %Load attribute image
                img = obj.Attributes(:,idx-3); 

                img = reshape(img, obj.ImageSize(1), obj.ImageSize(2)); 
           end
       end
       
       %Returns true if the image matching the index changes with a
       %new categorization
       function val = IsImageMappingCategories(obj, idx)
           val = false; 
           if(idx == 1)
               val = true; 
           end
       end
       
       %The specified categories have changed.  Those label maps must be
       %updated
       %First Optional Argument is a list of indicies to categories which
       %could have changed.  All others are assumed to be static
       function obj = UpdateLabelMap(obj, varargin)
                        
            optargin = size(varargin,2);

            %Parse the optional arguments
            if(optargin > 1)
                disp(['Too many arguments to UpdateLabelMap']); 
            end

            CategoryIndexImage = obj.CategoryIndexImage();
                        
            if(optargin > 0)
                ChangedCategories = varargin{1};
            else
                ChangedCategories = [1:obj.NumCategories]; 
                
                if(obj.NumCategories == 1)
                   obj.Categories{1}.Regions = [];  
                end
            end

            %LabelImage = ismember(CategoryIndexImage, ChangedCategories); 

            YDim = obj.ImageSize(1);
            XDim = obj.ImageSize(2);
            
            UpdatedLabelMaps = cell(1, length(ChangedCategories)); 
            
            %Slice the array for the parfor loop
            CategoryObjects = {obj.CategoryObjects.Members};

            %Making this a parfor incurs far too much overhead and memory
            %use
            parfor(iCategoryNumber = 1:length(ChangedCategories))
                CategoryNumber = ChangedCategories(iCategoryNumber); 
                LabelMap = cell(1,500); %Pre-allocate cell array
                iNextLabel = 1;
                LastMember = -1;
                LabelImage = (CategoryIndexImage ~= CategoryNumber); 
               
                %Every pixel in the class we assign a label to
                for(iPixel = CategoryObjects{CategoryNumber}')

                   %If the pixel is adjacent to the last pixel in the
                   %collection then we don't need to check for its
                   %region
                   if(iPixel - 1 == LastMember)
                       LastMember = iPixel; 
                       continue;
                   end
                   
                   if(mod(iPixel, obj.ImageSize(1)) == 0) 
                       LastMember = -1; 
                   else
                       LastMember = iPixel; 
                   end

                   %Check that the pixel isn't already assigned to a
                   %label
                   if(LabelImage(iPixel) ~= 0)
                       continue; 
                   end

                   [iY, iX] = ind2sub(obj.ImageSize,iPixel);

                   [LabelImage, newLabelCoords] = IterFill(CategoryIndexImage, LabelImage, XDim, YDim, iX, iY, CategoryNumber, 1);

                   iLabelCoords = sub2ind([YDim XDim], newLabelCoords(:,2), newLabelCoords(:,1)); 

                   LabelMap{iNextLabel} = iLabelCoords;
                   
                   iNextLabel = iNextLabel + 1; 
                   if(iNextLabel > length(LabelMap))
                      %Pre-allocate more array
                      LabelMap = [LabelMap cell(1,500)];
                   end
                end
                
                if(iNextLabel>1)
                    LabelMap = LabelMap(1:iNextLabel-1); 
                    UpdatedLabelMaps{iCategoryNumber} = LabelMap;
                else
                    UpdatedLabelMaps{iCategoryNumber} = {};
                end
                
                
    
                
            end
            
            for(iCategoryNumber = 1:length(ChangedCategories))
                CategoryNumber = ChangedCategories(iCategoryNumber); 
                obj.CategoryObjects(CategoryNumber).Regions = UpdatedLabelMaps{iCategoryNumber}; 
            end
            
       end
   end
end 
