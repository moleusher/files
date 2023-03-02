function S = extractAfter(STR, varargin)
%EXTRACTAFTER Create a string from part of a larger string.
%   S = EXTRACTAFTER(STR, START)
%   
%   See also EXTRACTAFTER, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 2);
S = codistributed.pElementwiseUnaryOp(@extractAfter, STR, varargin{:});
