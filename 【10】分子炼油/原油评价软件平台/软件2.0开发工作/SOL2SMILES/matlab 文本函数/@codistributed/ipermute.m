function A = ipermute(A, order)
%IPERMUTE Inverse permute codistributed array dimensions
%   A = IPERMUTE(B, ORDER)
%   
%   Example:
%   spmd
%       A = codistributed.rand(1,2,3,4);
%       B = permute(A, [3 2 1 4]); 
%       C = ipermute(B, [3 2 1 4]);
%       isequal(A, C) % A and C are equal
%   end
%   
%   See also IPERMUTE, PERMUTE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2011-2012 The MathWorks, Inc.

    narginchk(2, 2);

    distributedutil.CodistParser.verifyNonCodistributedInputs({A, order});
    order = distributedutil.CodistParser.gatherIfCodistributed(order);

    % if A isn't codistributed, call MATLAB function
    if ~isa(A, 'codistributed')
        A = ipermute(A, order);
        return
    end

    % Check order vector
    szA = size(A);
    lenSzA = length(szA);
    distributedutil.CodistParser.verifyPermuteOrderVector(order, lenSzA);

    % find out whether codistributor supports permute with this order
    lenOrder = numel(order);
    codistr = getCodistributor(A);
    if ~codistr.hPermuteCheck(lenOrder)
        [~, longDim] = max(szA);
        A = redistribute(A, codistributor1d(longDim));
        codistr = getCodistributor(A);
    end

    inverseorder(order) = 1:lenOrder;   % Inverse permutation order
    LPA = getLocalPart(A);
    [LPA, codistr] = codistr.hPermuteImpl(LPA, inverseorder);
    A = codistributed.pDoBuildFromLocalPart(LPA, codistr); %#ok<DCUNK>
end
