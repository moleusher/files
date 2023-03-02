function A = permute(A, order)
%PERMUTE Permute codistributed array dimensions
%   B = PERMUTE(A, ORDER)
%   
%   Example:
%   spmd
%       A = codistributed.rand(1,2,3,4);
%       size(permute(A,[3 2 1 4])) % now it's 3-by-2-by-1-by-4.
%   end
%   
%   See also PERMUTE, SIZE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2008-2012 The MathWorks, Inc.

    narginchk(2, 2);

    distributedutil.CodistParser.verifyNonCodistributedInputs({A, order});
    order = distributedutil.CodistParser.gatherIfCodistributed(order);

    % if A isn't codistributed, call MATLAB function
    if ~isa(A, 'codistributed')
        A = permute(A, order);
        return
    end

    % Check order vector
    szA = size(A);
    distributedutil.CodistParser.verifyPermuteOrderVector(order, length(szA));

    % find out whether codistributor supports permute with this order
    codistr = getCodistributor(A);
    if ~codistr.hPermuteCheck(numel(order))
        [~, longDim] = max(szA);
        A = redistribute(A, codistributor1d(longDim));
        codistr = getCodistributor(A);
    end

    LPA = getLocalPart(A);
    [LPA, codistr] = codistr.hPermuteImpl(LPA, order);
    A = codistributed.pDoBuildFromLocalPart(LPA, codistr); %#ok<DCUNK>
end
