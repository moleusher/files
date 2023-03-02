function b = reordercats(a, varargin)
%REORDERCATS Reorder categories in a categorical array.
%   
%   B = REORDERCATS(A)
%   B = REORDERCATS(A,NEWORDER)
%    
%   See also CATEGORICAL/REORDERCATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(1,2);
if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWORDER'));
end

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@reordercats, a, varargin{:});
