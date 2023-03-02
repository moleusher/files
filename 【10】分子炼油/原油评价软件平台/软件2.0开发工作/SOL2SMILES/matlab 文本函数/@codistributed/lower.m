function L = lower(U)
%LOWER Convert codistributed array of strings to lowercase.
%   B = LOWER(A)
%   
%   Note that A must be an array of strings or a cell array of char vectors.
%   
%   Example:
%   spmd
%       a = { 'Hello',  'goodBYE' };
%       A = codistributed(a)
%       B = lower(A)
%   end
%   
%   See also LOWER, CODISTRIBUTED/UPPER, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

L = codistributed.pElementwiseUnaryOp(@lower, U);
