function b = renamecats(a, varargin)
%RENAMECATS Rename categories in a categorical array.
%   
%   B = RENAMECATS(A,NAMES)
%   B = RENAMECATS(A,OLDNAMES,NEWNAMES)
%    
%   See also CATEGORICAL/RENAMECATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3); % renamecats(A,OLDNAMES,NEWNAMES)
if nargout == 0
    if nargin < 3
        error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWNAMES'));
    else
        error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLDNAMES,NEWNAMES'));
    end
end

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@renamecats, a, varargin{:});
