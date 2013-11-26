function [ RegularityIndex ] = VoronoiRegularityIndex( Centers, Limits, hAxes, color)
%REGULARITYINDEX - Returns the regularity index calculated by determining 
% mean voronoi area for every point divided by the standard deviation. 
%   Centers - two dimensional array of points in [y,x] order.
%   Limits - Optional parameter, extent of the plane the points exist on
%   hAxes - Optional parameter, output axes for results

RegularityIndex = 0;

if(nargin == 1)
    hAxes = [];
    Limits = max(points); 
elseif(nargin == 2)
    hAxes = [];
end

XSize = Limits(2); 
YSize = Limits(1); 

[v, c] = voronoin([Centers(:,2) Centers(:,1)]);

%Figure out which verticies are outside our image
OutsideV = zeros(length(v), 1);
for(iV = 2:length(v))
    if(v(iV, 2) < 0 || v(iV,2) > YSize)
        OutsideV(iV) = 1;
    end
    if(v(iV,1) < 0 || v(iV,1) > XSize)
       OutsideV(iV) = 1;
    end
end

if(~isempty(hAxes))
%    plot(hAxes, Centers(:,2), Centers(:,1),'+', 'color', [0 0 0]);
    hold on;
end

area = zeros(length(c), 1); 
for(i = 1:length(c))
    if(all(c{i} ~= 1))

        %Calculate area if the polygon is bounded by the image
        if(~any(OutsideV(c{i})))
            if(~isempty(hAxes))
                %'FaceAlpha', 0.5,
                patch(v(c{i}, 1), v(c{i}, 2), color, 'LineWidth', 1,  'LineStyle', ':');
            end
            area(i) = polyarea(v(c{i}, 1), v(c{i}, 2)); 
        end
    end
end


if(~isempty(hAxes))
    hold off; 
    set(hAxes, 'XLim', [0 XSize], ...
                       'YLim', [0 YSize], ...
                       'DataAspectRatio', [1 1 1], ...
                       'YDir', 'reverse');
end

%Calculate regularity index
%Remove empty areas
area(area == 0) = [];
if(length(area) > 1)
    mu = mean(area); 
    sigma = std(area);

    RegularityIndex = mu / sigma; 

    %Temp
%        I = getframe(thisObj.hAxes); 
%        imwrite(I.cdata, ['voronoi_' get(Categories(iCat), 'name') '.png']);
%        drawnow;
end
