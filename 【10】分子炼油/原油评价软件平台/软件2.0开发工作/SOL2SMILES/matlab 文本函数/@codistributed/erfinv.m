function Y = erfinv(X)
%ERFINV Inverse error function of codistributed array
%   Y = ERFINV(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = erfinv(D)
%   end
%   
%   See also ERF, ERFC, ERFCX, ERFCINV,  CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@erfinv, X);
