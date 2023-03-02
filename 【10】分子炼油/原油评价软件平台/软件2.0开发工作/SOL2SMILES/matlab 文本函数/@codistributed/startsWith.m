function tf = startsWith(s, varargin)
%STARTSWITH True if string starts with pattern
%   
%   TF = STARTSWITH(S,PATTERN)
%   TF = STARTSWITH(S,PATTERN,'IgnoreCase',IGNORE)
%   
%   See also STARTSWITH.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 4);
tf = codistributed.pElementwiseUnaryOp(@startsWith, s, varargin{:});
