function b = removecats(a, varargin)
%REMOVECATS Remove categories from a categorical array.
%   
%   B = REMOVECATS(A,OLDCATEGORIES)
%    
%   See also CATEGORICAL/REMOVECATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(1,2);
if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLD'));
end

if nargin<2
    % Determine unused categories
    allCats = categories(a);
    localCats = unique(getLocalPart(a));
    usedCats = categories( removecats( gop(@iUnique, localCats) ) );
    args = {setdiff(allCats, usedCats)};
else
    args = varargin;
end

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@removecats, a, args{:});
end % removecats

function c = iUnique(a,b)
c = unique([a;b]);
end
