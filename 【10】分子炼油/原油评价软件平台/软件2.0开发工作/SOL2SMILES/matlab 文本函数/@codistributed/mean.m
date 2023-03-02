function y = mean(x, varargin)
%MEAN Average or mean value of codistributed array
%   S = MEAN(X)
%   S = MEAN(X,DIM)
%   S = MEAN(...,'double')
%   S = MEAN(...,'default')
%   S = MEAN(...,'omitnan')
%   S = MEAN(...,'includenan')
%   
%   The 'native' option is not supported.
%   
%   Example:
%   spmd
%       N = 10000;
%       X = codistributed.colon(-N, N);
%       m = mean(X);
%       isequal(m, codistributed(0)) % true
%   end
%   
%   See also MEAN, CODISTRIBUTED, CODISTRIBUTED/MIN, CODISTRIBUTED/MAX,
%            codistributed/SUM.

%   Copyright 2013-2014 The MathWorks, Inc.

% Check for valid input types
distributedutil.CodistParser.verifyNonCodistributedInputs([{x}, varargin]);

% Make sure dim and flag are not distributed, they will error
varargin = distributedutil.CodistParser.gatherElements(varargin);

% If 'x' is not codistributed, use the host version
if ~isa(x, 'codistributed')
    y = mean(x, varargin{:});
    return;
end

% try...catch prevents error being reported by internal
try
    y = parallel.internal.flowthrough.mean(x, varargin{:});
catch ME
    throw(ME);
end
