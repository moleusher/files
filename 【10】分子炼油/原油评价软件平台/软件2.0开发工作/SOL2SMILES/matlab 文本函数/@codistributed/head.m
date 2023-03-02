function h = head(A,K)
%HEAD Return the first few rows of codistributed array.
%   
%   TY = HEAD(TX) returns the first few rows of codistributed array TX. The result
%   is a new codistributed array TY.
%    
%   TY = HEAD(TX, K) returns up to K rows from the beginning of codistributed array
%   TX. If TX contains fewer than K rows, the entire array is returned.
%    
%   See also: CODISTRIBUTED/TAIL, CODISTRIBUTED.
%   
%   


%   Copyright 2016 The MathWorks, Inc.

if nargin<2
    K = matlab.bigdata.internal.util.defaultHeadTailRows();
else
    % Check that k is a non-negative integer-valued scalar
    validateattributes(K, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'head', 'k')
end
if K>size(A,1)
    % Not enough rows, so return everything
    h = A;
else
    subs = repmat({':'},1,ndims(A));
    subs{1} = 1:K;
    h = subsref(A, substruct('()',subs));
end
