function Y = csc(X)
%CSC Cosecant of codistributed array in radians
%   Y = CSC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = csc(D)
%   end
%   
%   See also CSC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

if nargin==0
  error(message('parallel:distributed:CscNotEnoughInputs'));
end

Y = codistributed.pElementwiseUnaryOp(@csc, X);
