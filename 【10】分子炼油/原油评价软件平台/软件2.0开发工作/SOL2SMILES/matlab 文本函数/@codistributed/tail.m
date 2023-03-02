function t = tail(A,K)
%TAIL Return the last few rows of codistributed array.
%   
%   TY = TAIL(TX) returns the last few rows of codistributed array TX. The result
%   is a new codistributed array TY.
%    
%   TY = TAIL(TX, K) returns up to K rows from the end of codistributed array
%   TX. If TX contains fewer than K rows, the entire array is returned.
%    
%   See also: CODISTRIBUTED/HEAD, CODISTRIBUTED.
%   
%   


%   Copyright 2016 The MathWorks, Inc.

if nargin<2
    K = matlab.bigdata.internal.util.defaultHeadTailRows();
else
    % Check that k is a non-negative integer-valued scalar
    validateattributes(K, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'tail', 'k')
end
if K>size(A,1)
    % Not enough rows, so return everything
    t = A;
else
    subs = repmat({':'},1,ndims(A));
    subs{1} = size(A,1)+(1-K:0);
    t = subsref(A, substruct('()',subs));
end
