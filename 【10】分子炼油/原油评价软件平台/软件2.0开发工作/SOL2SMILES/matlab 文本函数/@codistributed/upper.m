function U = upper(L)
%UPPER Convert codistributed array of strings to uppercase.
%   B = UPPER(A)
%   
%   Note that A must be an array of strings or a cell array of char vectors.
%   
%   Example:
%   spmd
%       a = { 'Hello',  'goodbye' };
%       A = codistributed(a)
%       B = upper(A)
%   end
%   
%   See also UPPER, CODISTRIBUTED/LOWER, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

U = codistributed.pElementwiseUnaryOp(@upper, L);
