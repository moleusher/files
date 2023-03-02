function b = addcats(a, varargin)
%ADDCATS Add categories to a codistributed categorical array.
%   
%   B = ADDCATS(A,NEWCATEGORIES)
%   B = ADDCATS(A,NEWCATEGORIES,'After',WHERE)
%   B = ADDCATS(A,NEWCATEGORIES,'Before',WHERE)
%    
%   See also CATEGORICAL/ADDCATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,4); % addcats(A,NEWCATEGORIES,'After',WHERE)

% If the user forgets to capture the modified output, error
if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEW,...'));
end

% Simply apply to all elements (trailing args will be broadcast)
b = codistributed.pElementwiseUnaryOp(@addcats, a, varargin{:});
