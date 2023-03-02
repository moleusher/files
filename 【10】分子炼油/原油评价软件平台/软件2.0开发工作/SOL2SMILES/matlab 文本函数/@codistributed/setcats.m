function b = setcats(a, varargin)
%SETCATS Set the categories of a categorical array.
%   
%   B = SETCATS(A,NEWCATEGORIES)
%    
%   See also CATEGORICAL/SETCATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWCATEGORIES'));
end
narginchk(2,2);

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@setcats, a, varargin{:});
