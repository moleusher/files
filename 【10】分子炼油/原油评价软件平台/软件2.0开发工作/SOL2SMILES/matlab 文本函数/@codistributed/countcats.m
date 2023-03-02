function c = countcats(a, dim)
%COUNTCATS Count occurrences of categories in a codistributed categorical array's elements.
%   
%   C = COUNTCATS(A)
%   C = COUNTCATS(A,DIM) 
%    
%   See also CATEGORICAL/COUNTCATS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

% COUNTCATS doesn't obey the traditional reduction rules, so we do
% something special. 1D only for now.
if nargin == 2
    distributedutil.CodistParser.verifyNonCodistributedInputs({a, dim});
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isa(a, 'codistributed')
        % Run on client
        c = countcats(a, dim);
        return;
    end
    iCheckDimArg(dim);
    
else
    % Get dim as last non-singular
    dim = distributedutil.Sizes.firstNonSingletonDimension(size(a));
end

% The implementation is different for different distribution schemes...
codistr = getCodistributor(a);
LP = getLocalPart(a);
[LP, codistr] = codistr.hCountcatsImpl(LP, dim);
c = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> Calling private static method.

end


function iCheckDimArg(dim)
% Sanity check dimension argument
if ~isscalar(dim) || dim<=0 || dim~=round(dim)
    error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
end
end