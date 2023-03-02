function tf = contains(s, varargin)
%CONTAINS True if pattern is found in string
%   
%   TF = CONTAINS(S,PATTERN)
%   TF = CONTAINS(S,PATTERN,'IgnoreCase',IGNORE)
%   
%   See also CONTAINS.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 4);
tf = codistributed.pElementwiseUnaryOp(@contains, s, varargin{:});
