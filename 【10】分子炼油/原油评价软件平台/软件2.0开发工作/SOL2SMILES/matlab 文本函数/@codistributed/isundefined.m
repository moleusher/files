function tf = isundefined(a)
%ISUNDEFINED True for elements of a categorical array that are undefined.
%   
%   TF = ISUNDEFINED(A)
%    
%   See also CATEGORICAL/ISUNDEFINED, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = codistributed.pElementwiseUnaryOp(@isundefined, a);
