function [ Similiarity ] = SeperabilityScore( varargin )
%SIMILIARITYSCORE - Given two distributions returns a score indicating how
%similiar the two distributions are.  This is done by fiting a normal
%distribution to each.  The areas on each normal distribution with a probability
%greater than alpha which overlap areas on the other distribution greater
%than alpha are then summed. 
%There are two versions of this function:  
%   SimiliarityScore(ScalarsA, ScalarsB, alpha , hAxes); - scalars is an array of 1-D values  
%  
%   SimiliarityScore(PointsA, PointsB, alpha, hAxes); - Points is a 2-D array of
%       positions in N-space.  The optimal seperation vector is calculated and
%       a score returned based upon that vector. 
%
%   Arguments:
%   alpha - optional, if not specified the default value of .001 is used. 
%   hAxes - optional, if specified the resulting distributions are plotted
%       on hAxes
%   colors - optional, if specified determines the color of the
%       distribution plots

if(nargin < 3)
    alpha = .001;
else
    alpha = varargin{3}; 
end

hAxes = []; 
if(nargin >= 4)
    hAxes = varargin{4};
end

colors = [1 0 0; 0 0 1];
if(nargin >= 5)
    colors = varargin{5};
end

ScalarA = []; 
ScalarB = []; 

%Determine if we have an array of points or a set of scalar values
[numPts, numCoords] = size(varargin{1});
if(numCoords > 1)
    %Need to project points onto a vector
    PtsA = varargin{1};
    PtsB = varargin{2}; 
    
    V = OptimalSeparabiltyVector(PtsA, PtsB); 
    ScalarA = ProjectOntoVector(V, PtsA); 
    ScalarB = ProjectOntoVector(V, PtsB);
else
    ScalarA = varargin{1}; 
    ScalarB = varargin{2};
end

%Determine statistical properties of the data assuming they are part of a
%normal distribution
[muA, sigmaA] = normfit(ScalarA);
[muB, sigmaB] = normfit(ScalarB);

if(sigmaA == 0)
    sigmaA = 0.5;
end
if(sigmaB == 0)
    sigmaB = 0.5;
end

%Determine the extents of the data
Low = min([min(ScalarA) min(ScalarB)]); 
High = max([max(ScalarA) max(ScalarB)]);

%Determine bin boundaries of histogram
StepSize = .25;
NormEdges = Low-1:StepSize:High+1;

%Calculate the normal distributions
NormA = normpdf(NormEdges, muA, sigmaA);
NormB = normpdf(NormEdges, muB, sigmaB);

%Integrate the area under the curves which have values greater than .001
%Find all indicies with values that meet our threshold
iA = find(NormA >= alpha);
iB = find(NormB >= alpha);

%Remove all nonmatching indicies
iIntegral = intersect(iA,iB); 

%The normal doesn't sum to 1 if the stepsize is any value other than one,
%so we need to correct for this
IntegralA = sum(NormA(iIntegral))  / (1 / StepSize);
IntegralB = sum(NormB(iIntegral))  / (1 / StepSize);

Similiarity = IntegralA + IntegralB;

%Plot the results
if(~isempty(hAxes))
    PlotA = NormA .* length(ScalarA); 
    PlotB = NormB .* length(ScalarB); 

    hold(hAxes, 'on');
    plot(hAxes, NormEdges, PlotA, 'linewidth', 2, 'Color', colors(1,:) );
    plot(hAxes, NormEdges, PlotB, 'linewidth', 2, 'Color', colors(2,:) ); 

    text(0, 1, ['Similarity score: ' num2str(Similiarity)], ...
         'parent', hAxes, ...
         'units', 'normalized', ...
         'VerticalAlignment', 'bottom', ...
         'FontSize', 14); 
     
    hold(hAxes, 'off');
end

