function Y = sec(X)
%SEC Secant of codistributed array in radians
%   Y = SEC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = sec(D)
%   end
%   
%   See also SEC, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@sec, X);
