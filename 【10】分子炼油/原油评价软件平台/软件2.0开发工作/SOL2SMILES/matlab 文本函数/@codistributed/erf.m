function Y = erf(X)
%ERF Error function of codistributed array
%   Y = ERF(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = erf(D)
%   end
%   
%   See also ERFC, ERFCX, ERFINV, ERFCINV,  CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@erf, X);
