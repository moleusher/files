function modstr = replaceBetween(origstr,varargin)
%REPLACEBETWEEN Replace a substring specified by bounds with new text.
%   S = REPLACEBETWEEN(STR, START, END, TEXT)
%   S = REPLACEBETWEEN(STR, START_STR, END_STR, TEXT)
%   S = REPLACEBETWEEN(..., 'Boundaries', B)
%   
%   See also REPLACEBETWEEN, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(4,inf);

% All inputs except first are treated as gathered. Output is same size and
% type as first input.
modstr = codistributed.pElementwiseUnaryOp(@replaceBetween, origstr, varargin{:});