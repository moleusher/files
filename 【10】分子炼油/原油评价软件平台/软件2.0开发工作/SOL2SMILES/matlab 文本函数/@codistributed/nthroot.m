function y = nthroot(x, n)
%NTHROOT Real n-th root of real numbers
%   Y = NTHROOT(X,N)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -2*codistributed.ones(N);
%       E = D.^(1/3)
%       F = nthroot(D,3)
%   end
%   
%   See also NTHROOT, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

if ~isreal(x) || ~isreal(n)
   error(message('parallel:distributed:NthrootComplexInput'));
end

y = codistributed.pElementwiseOp(@nthroot, x, n);
