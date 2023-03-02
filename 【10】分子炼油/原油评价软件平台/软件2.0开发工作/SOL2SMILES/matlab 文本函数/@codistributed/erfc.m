function Y = erfc(X)
%ERFC Complementary error function of codistributed array
%   Y = ERFC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = erfc(D)
%   end
%   
%   See also ERF, ERFCX, ERFINV, ERFCINV, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@erfc, X);
