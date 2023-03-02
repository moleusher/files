function p = nextpow2(n)
%NEXTPOW2 Next higher power of 2 for codistributed arrays
%   
%   Y = NEXTPOW2(X)
%   
%   Examples:
%   spmd
%       D = codistributed(pi)
%       E = nextpow2(D)
%   end
%   
%   spmd
%       X = codistributed.colon(1, 5)
%       Y = nextpow2(X)
%   end
%   
%   See also NEXTPOW2, CODISTRIBUTED, CODISTRIBUTED/COLON.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

p = codistributed.pElementwiseUnaryOp(@nextpow2, n); %#ok<DCUNK>
