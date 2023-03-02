function Z = any(varargin)
%ANY True if any element of a codistributed vector is nonzero or TRUE
%   A = ANY(D)
%   A = ANY(D,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       t = any(D,1)
%   end
%   
%   returns t the codistributed row vector equal to
%   codistributed.true(1,N).
%   
%   See also ANY, CODISTRIBUTED, CODISTRIBUTED/EYE, CODISTRIBUTED/TRUE.


%   Copyright 2006-2010 The MathWorks, Inc.

Z = codistributed.pReductionOpAlongDim(@any,varargin{:});
