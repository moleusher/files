function out = superiorfloat( varargin )
%SUPERIORFLOAT return 'double' or 'single' based on the superior input.
%   SUPERIORFLOAT(A,B,...)
%   
%   Example:
%   spmd
%       A = codistributed.ones(5,'single');
%       B = ones(3,'double')
%       superiorfloat(A,B)
%   end
%   
%   See also SUPERIORFLOAT, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2014-2015 The MathWorks, Inc.

out = 'double';
for ii=1:nargin
    arg = varargin{ii};

    % logical and char counts as double (never dominant)
    if ischar(arg) || islogical(arg)
       continue;
    end
    
    % non-floats should error
    if ~isfloat(arg)
       error(message('MATLAB:datatypes:superiorfloat'));
    end
    
    % single dominates double
    if isequal(parallel.internal.array.typeof(arg), 'single')
       out = 'single';
    end

end

