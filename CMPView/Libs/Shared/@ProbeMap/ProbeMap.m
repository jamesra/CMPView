function [ obj ] = ProbeMap( varargin )
%CATEGORYVIEW Summary of this function goes here
%   Detailed explanation goes here

obj.XlsPath = '';
obj.NameMap = {}; 

switch nargin
    case 0
        obj = class(obj, 'ProbeMap');
        obj.XlsPath = pwd;
        return
    case 1
        if isa(varargin(1), 'ProbeMap')
            obj = varargin(1);
        elseif( isstr(varargin{1}))
            obj.XlsPath = varargin{1};
           
            obj = class(obj, 'ProbeMap');
        else
            error('Single argument to Probes constructor must be Probes object or path string');
        end
    otherwise
        error('Wrong number of input arguments');
end

%The probe name information is stored in an xls sheet that lists the probe
%code in the first column, and the full probe name in the second. 

try
    [junk, probnames] = xlsread(obj.XlsPath, 'A2:B2000');

    obj.NameMap = probnames;
catch
    disp(['Unable to load probe name XLS file: ' obj.XlsPath]);
end