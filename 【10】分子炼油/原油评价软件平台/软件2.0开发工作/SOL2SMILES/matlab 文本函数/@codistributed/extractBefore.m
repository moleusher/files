function S = extractBefore(STR, varargin)
%EXTRACTBEFORE Create a string from part of a larger string.
%   S = EXTRACTBEFORE(STR, END)
%   
%   See also EXTRACTBEFORE, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 2);
S = codistributed.pElementwiseUnaryOp(@extractBefore, STR, varargin{:});
