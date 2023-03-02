function C = hBuildFromTemplate(template, sz, varargin)
%hBuildFromTemplate Hidden static method to build codistributed arrays by
%   replicating a template element.  All errors are thrown as caller.
%      
%   See also codistributed/pBuildFromFcn.
%   


%   Copyright 2016 The MathWorks, Inc.

% This error should never be triggered since this is a hidden function.
narginchk(2, 4); % Allow trailing codistributor specification

assert(isscalar(template));

try
    [~, codistr] = distributedutil.CodistParser.extractCodistributor(varargin);
    % Ask the codistributor to build the local part
    [LP, codistr] = codistr.hBuildFromTemplateImpl(template, sz);
catch E
    throwAsCaller(E)
end

% Put the local parts into a codistributed
C = codistributed.pDoBuildFromLocalPart(LP, codistr);  %#ok<DCUNK>

end % hBuildFromTemplate
