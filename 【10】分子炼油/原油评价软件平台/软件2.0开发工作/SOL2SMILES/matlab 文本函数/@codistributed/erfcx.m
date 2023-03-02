function Y = erfcx(X)
%ERFCX Scaled complementary error function of codistributed array
%   Y = ERFCX(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = erfcx(D)
%   end
%   
%   See also ERF, ERFINV, ERFC, ERFCINV, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@erfcx, X);
