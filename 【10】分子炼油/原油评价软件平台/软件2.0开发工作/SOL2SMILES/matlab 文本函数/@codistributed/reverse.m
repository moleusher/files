function A = reverse(S)
%REVERSE Reverse the order of characters in string
%   
%   A = REVERSE(S)
%   
%   See also REVERSE.
%   


%   Copyright 2016 The MathWorks, Inc.

A = codistributed.pElementwiseUnaryOp(@reverse, S);