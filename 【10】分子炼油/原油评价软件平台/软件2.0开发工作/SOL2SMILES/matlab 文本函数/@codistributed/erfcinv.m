function Y = erfcinv(X)
%ERFCINV Inverse complementary error function of codistributed array
%   Y = ERFCINV(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = erfcinv(D)
%   end
%   
%   See also ERF, ERFC, ERFCX, ERFINV, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@erfcinv, X);
