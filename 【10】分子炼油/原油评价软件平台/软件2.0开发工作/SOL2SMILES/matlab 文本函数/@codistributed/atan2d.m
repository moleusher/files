function Z = atan2d(Y,X)
%ATAN2D Four quadrant inverse tangent of codistributed array, result in degrees
%   Z = ATAN2D(Y,X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atan2d(D,D)
%   end
%   
%   See also ATAN2D, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2011-2014 The MathWorks, Inc.

Z = codistributed.pElementwiseOp(@atan2d, Y, X); %#ok<DCUNK>
