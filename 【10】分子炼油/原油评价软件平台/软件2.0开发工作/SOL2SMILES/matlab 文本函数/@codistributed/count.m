function c = count(s, varargin)
%COUNT Returns the number of occurrences of a pattern in a string
%   
%   C = COUNT(S,PATTERN)
%   C = COUNT(S,PATTERN,'IgnoreCase',IGNORE)
%   
%   See also COUNT.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 4);
c = codistributed.pElementwiseUnaryOp(@count, s, varargin{:});
