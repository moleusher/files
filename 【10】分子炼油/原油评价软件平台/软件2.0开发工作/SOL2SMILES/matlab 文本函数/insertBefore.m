function S = insertBefore(STR, varargin)
%INSERTBEFORE Insert text before a specified position.
%   S = INSERTBEFORE(STR, POS, TEXT)
%   
%   See also INSERTBEFORE, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, inf);
S = pElementwiseUnaryOp(@insertBefore, STR, varargin{:});
