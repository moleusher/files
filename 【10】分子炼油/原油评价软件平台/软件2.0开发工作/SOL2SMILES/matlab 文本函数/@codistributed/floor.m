function Y = floor(X)
%FLOOR Round codistributed array towards minus infinity
%   Y = FLOOR(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)./2
%       E = floor(D)
%   end
%   
%   See also FLOOR, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@floor, X);
