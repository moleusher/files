function X = pow2(F,E)
%POW2 Base 2 power and scale floating point number for codistributed array
%   X = POW2(Y) for each element of codistributed array Y is 2 raised to the power Y.
%   
%   X = POW2(F,E) for each element of the codistributed array F and a integer
%   codistributed array E computes codistributed array X = F .* (2 .^ E).  The 
%   result is computed quickly by simply adding E to the floating point exponent 
%   of F.  This corresponds to the ANSI C function ldexp() and the IEEE
%   floating point standard function scalbn().
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N)
%       E = pow2(D)
%   end
%   
%   See also POW2, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2014 The MathWorks, Inc.

if nargin == 1
   X = codistributed.pElementwiseUnaryOp(@pow2, F);
else
   X = codistributed.pElementwiseOp(@pow2, F, E);
end

