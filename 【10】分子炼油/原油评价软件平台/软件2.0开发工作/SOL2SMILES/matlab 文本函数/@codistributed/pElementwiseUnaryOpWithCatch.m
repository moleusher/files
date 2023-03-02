function A = pElementwiseUnaryOpWithCatch(F, A)
%pElementwiseUnaryOpWithCatch  Perform elementwise unary operations inside try-catch
%   D2 = codistributed.pElementwiseUnaryOpWithCatch(F, D1) performs the elementwise unary
%   operation F on all elements of D1 inside a try-catch block so as to achieve
%   collective error handling.  Any errors are thrown as the caller.

%   Copyright 2006-2016 The MathWorks, Inc.

codistr = getCodistributor(A);
LP = getLocalPart(A);
clear A;

try
    elementwiseUnary = @() codistr.hElementwiseUnaryOpImpl(F,  LP);
    % Call hElementwiseUnaryOpImpl with two output arguments, but synchronize the
    % error behavior.
    [LP, codistr] = distributedutil.syncOnError(elementwiseUnary);
catch E
    throwAsCaller(dispatchUndefinedFunctionException(E));
end

A = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end
