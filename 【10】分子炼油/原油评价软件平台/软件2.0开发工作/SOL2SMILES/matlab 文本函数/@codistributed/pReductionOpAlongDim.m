function D = pReductionOpAlongDim(F, A, dim)
%pReductionOpAlongDim Perform a reduction operation with an optional dim argument
%   D2 = codistributed.pReductionOpAlongDim(F, D1) and
%   D2 = codistributed.pReductionOpAlongDim(F, D1, dim) performs the reduction
%   operation F on all elements of D1 along the default dimension, or, if
%   specified, along the dimension dim.


%   Copyright 2006-2013 The MathWorks, Inc.

if nargin == 3
    distributedutil.CodistParser.verifyNonCodistributedInputs({A, dim});
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isa(A, 'codistributed')
        % The dimension was a codistributed singleton.
        try
            D = F(A, dim);
            return;
        catch E
            throwAsCaller(E);
        end
    end
    try
        iCheckDimArg(dim);
    catch E
        throwAsCaller(E);
    end
else
    dim = 0;
end
% Note that the reduction op cannot assumed to be a no-op when dim > ndims(A)
% because the reduction op may change the class of the result.  For example,
% the result of any([2, 2], 10) is the logical array [1, 1].

codistr = getCodistributor(A);
LP = getLocalPart(A);
[LP, codistr] = codistr.hReductionOpAlongDimImpl(F,  LP, dim);
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> Calling private static method.


function iCheckDimArg(dim)
% Sanity check dimension argument
if ~isscalar(dim) || dim<=0 || dim~=round(dim)
    error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
end