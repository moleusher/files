function C = char(D)
%CHAR Convert a codistributed array to a codistributed character array (string)
%   S = CHAR(X)
%   
%   The syntax S = CHAR(T1,T2,T3, ...) is not supported.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 65*codistributed.ones(N,'uint16');
%       C = char(D)
%       classD = classUnderlying(D)
%       classC = classUnderlying(C)
%   end
%   
%   converts the N-by-N codistributed uint16 matrix D into a
%   codistributed char array C.
%   classD is 'uint16' while classC is 'char'.
%   
%   See also CHAR, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2011 The MathWorks, Inc.

C = codistributed.pElementwiseUnaryOp(@char,D);
