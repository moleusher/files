function B = redistribute(A, destCodistr)
%REDISTRIBUTE Redistribute a codistributed array with another codistributor
%   D2 = REDISTRIBUTE(D1, CODISTR) redistributes a codistributed array D1 to
%   have the distribution scheme CODISTR.
%   
%   Example:
%   spmd
%       N = 1000;
%       M = codistributed(magic(N), codistributor('1d', 2));
%       P = codistributed(pascal(N), codistributor('1d', 1));
%       R = redistribute(P, getCodistributor(M));
%   end
%   
%   See also CODISTRIBUTED, CODISTRIBUTOR/CODISTRIBUTOR.


%   Copyright 2006-2016 The MathWorks, Inc.

narginchk(2, 2);

if ~isa(A, 'codistributed')
    error(message('parallel:distributed:RedistributeFirstInput'))
end

if ~isa(destCodistr, 'AbstractCodistributor')
    error(message('parallel:distributed:RedistributeSecondInput', class( destCodistr )))
end

LP = getLocalPart(A);
codistr = getCodistributor(A);

if istable(A)
    % For tables we also need the global variable names and types so that
    % we can build the right local part.
    tableTemplate = getTableTemplate(A);
    [LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, destCodistr, tableTemplate);
else
    [LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, destCodistr);
end

B = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>

