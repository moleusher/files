function [e, cnt] = normest(varargin)
%NORMEST Estimate the codistributed matrix 2-norm
%   nrm = NORMEST(S)
%   nrm = NORMEST(S,TOL)
%   [nrm,cnt] = NORMEST(...)
%   
%   Class support for input S:
%       float: double, single
%       logical
%   
%   Example:
%   spmd
%       n = 1000;
%       S = diag(codistributed.colon(1,n));
%       nrm = normest(S, 1.0e-4)
%   end
%   
%   See also NORMEST, CODISTRIBUTED, CODISTRIBUTED/NORM, CODISTRIBUTED/COLON, CODISTRIBUTED/DIAG.


%   Copyright 2006-2016 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [e, cnt] = parallel.internal.flowthrough.normest(varargin{:});
catch ME
    throw(ME);
end
end