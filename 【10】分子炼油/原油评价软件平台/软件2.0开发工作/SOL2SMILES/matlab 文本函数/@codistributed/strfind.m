function ind = strfind(text, varargin)
%STRFIND  Find one string within another.
%   K = STRFIND(TEXT,PATTERN)
%   
%   Note that TEXT must be a codistributed array of strings or cell array
%   of char vectors. The output is always a cell array of index vectors.
%   
%   Example:
%   spmd
%       s = {'How much wood'; 'would a woodchuck chuck?'};
%       S = codistributed(s);
%       strfind(S,'wo')
%   end
%   
%   See also STRFIND, CODISTRIBUTED.
%   
%   


%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(2, 4);

% If the pattern or subsequent args are distributed, gather them now.
argList = distributedutil.CodistParser.gatherElements(varargin);

if ~iscodistributed(text)
    % Trailing parameters are codistributed, but not the array itself. Use
    % the normal MATLAB version with the gathered arguments.
    ind = strfind(text, argList{:});
    return;
end

% The first input must be an array of strings. The others are just bound in
% and used for each element.
if ~isStringArray(text)
    error(message('parallel:distributed:NotStringArray', 'STRFIND'));
end

% A scalar string input can produce a row vector output. String arrays
% produce cell arrays in an element-wise manner
if isstring(text) && isscalar(text)
    % Scalar might expand to row vector
    lp = getLocalPart(text);
    indLp = strfind(lp, argList{:});
    codistr = codistributor1d(1, codistributor1d.unsetPartition, size(indLp));
    ind = codistributed.pDoBuildFromLocalPart(indLp, codistr);
else
    % One output element for each input element.
    ind = codistributed.pElementwiseUnaryOp(@(x) iWrapStrfind(x, argList{:}), text);
end
end

function out = iWrapStrfind(in, varargin)
% To avoid problems with local workers only having a single element force
% return of a cell array.
out = strfind(in, varargin{:});
if ~iscell(out)
    out = {out};
end
end
