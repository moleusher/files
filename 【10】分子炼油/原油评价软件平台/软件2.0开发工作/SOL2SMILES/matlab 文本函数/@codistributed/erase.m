function S = erase(STR, varargin)
%ERASE Remove segments from string elements.
%   
%   S = ERASE(STR,START)
%   S = ERASE(STR,START,END)
%   S = ERASE(STR,START_STR,END_STR)
%   
%   See also ERASE.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2, inf);
S = codistributed.pElementwiseUnaryOp(@erase, STR, varargin{:});
