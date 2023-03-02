function nzmx = nzmax(S)
%NZMAX Amount of storage allocated for nonzero codistributed matrix elements
%   N = NZMAX(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N);
%       n = nzmax(D)
%   end
%   
%   returns n = N.
%   
%   t = issparse(D)
%   
%   returns t = true.
%   
%   See also NZMAX, CODISTRIBUTED, CODISTRIBUTED/SPEYE.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

sDist = getCodistributor(S);
localS = getLocalPart(S);

nzmx = sDist.hNzmaxImpl(localS);
