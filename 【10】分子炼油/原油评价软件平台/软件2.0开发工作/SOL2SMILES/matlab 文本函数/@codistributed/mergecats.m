function b = mergecats(a, varargin)
%MERGECATS Merge categories in a codistributed categorical array.
%   
%   B = MERGECATS(A,CATEGORIES)
%   B = MERGECATS(A,OLDCATEGORIES,NEWCATEGORY)
%    
%   See also CATEGORICAL/MERGECATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3); % mergecats(A,OLDCATEGORIES,NEWCATEGORY)
if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLD,NEW'));
end

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@mergecats, a, varargin{:});
