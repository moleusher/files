function P = angle(H)
%ANGLE Phase angle of codistributed array
%   Y = ANGLE(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 1i * codistributed.ones(N);
%       E = angle(D)
%   end
%   
%   See also ANGLE, CODISTRIBUTED, CODISTRIBUTED/SQRT.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

P = codistributed.pElementwiseUnaryOp(@angle, H);
