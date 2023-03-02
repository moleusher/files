function S = insertAfter(STR, varargin)
%INSERTAFTER Insert text after a specified position.
%   S = INSERTAFTER(STR, POS, TEXT)
%   
%   See also INSERTAFTER, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(3, 3);
S = codistributed.pElementwiseUnaryOp(@insertAfter, STR, varargin{:});
