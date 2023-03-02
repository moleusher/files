function tf = endsWith(s, varargin)
%ENDSWITH True if string ends with pattern
%   
%   TF = ENDSWITH(S,PATTERN)
%   TF = ENDSWITH(S,PATTERN,'IgnoreCase',IGNORE)
%   
%   See also ENDSWITH.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 4);
tf = codistributed.pElementwiseUnaryOp(@endsWith, s, varargin{:});
