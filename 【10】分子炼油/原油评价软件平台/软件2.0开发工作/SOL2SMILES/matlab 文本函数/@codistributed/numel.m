function n = numel( obj, varargin )
%NUMEL Number of elements in codistributed array or subscripted array expression
%   N = NUMEL(A) returns the number of underlying elements, N, in codistributed 
%   array A.
%   
%   N = NUMEL(A, INDEX1, INDEX2, ...) returns in N the number of 
%   subscripted elements in codistributed array A(index1, index2, ...).
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.ones(3,4,N);
%       ne = numel(A)
%   end
%   
%   returns ne = 12000.
%   
%   See also NUMEL, CODISTRIBUTED.
%   


%   Copyright 2008-2016 The MathWorks, Inc.

n = distributedutil.numelHelper(size(obj), istable(obj), varargin{:});

