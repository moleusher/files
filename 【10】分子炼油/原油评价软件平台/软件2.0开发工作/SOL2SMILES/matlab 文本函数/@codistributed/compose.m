function s = compose(format,varargin)
%COMPOSE Fill holes in string with formatted data.
%   S = COMPOSE(TXT)
%   S = COMPOSE(FORMAT,A)
%   S = COMPOSE(FORMAT,A1,...,AN)
%   
%   See also COMPOSE, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

if nargin==1
    % With one-input, this is simply an element-wise call
    if ~isStringArray(format)
        error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(format)));
    end
    s = codistributed.pElementwiseUnaryOp(@compose, format);
    
else
    % Because multi-input COMPOSE can consume multiple columns of the input
    % arrays, we need workers to have whole rows. Redistributed to 1D in
    % the first dimension.
    [codistr, varargin] = iEnsureRowDistribution(varargin);
    
    % Now just work on the local part
    lp_in = cellfun(@getLocalPart, varargin, 'UniformOutput', false);
    lp = compose(format, lp_in{:});
    
    % Output has same number of rows (and hence partitioning) as input
    sSize = size(lp);
    sSize(1) = sum(codistr.Partition);
    sDist = codistributor1d(1, codistr.Partition, sSize);
    
    % Build output
    s = codistributed.pDoBuildFromLocalPart(lp, sDist);
    
end
end % compose

function [codistr, args] = iEnsureRowDistribution(args)
% Ensure all codistributed inputs are distributed by rows with the same
% distribution.

% Work out which inputs are codistributed. There should be at least one.
isCodistributed = cellfun(@(x) isa(x,'codistributed'), args);
firstCodistributed = find(isCodistributed, 1, 'first');
codistr = getCodistributor(args{firstCodistributed});

if ~isa(codistr, 'codistributor1d') || codistr.Dimension~=1
    args{firstCodistributed} = redistribute(args{firstCodistributed}, codistributor('1d',1));
    codistr = getCodistributor(args{firstCodistributed});
end

% Redistribute them all
args = cellfun(@(x) iMaybeRedistribute(x, codistr), args, 'UniformOutput', false);

end % iEnsureRowDistribution

function x = iMaybeRedistribute(x, codistr)
% redistribute an input if its distribution differs
if iscodistributed(x)
    if ~isequal(getCodistributor(x), codistr)
        x = redistribute(x, codistr);
    end
else
    % Input is replicated. Convert to codistributed.
    x = codistributed.pConstructFromReplicated(x, codistr); %#ok<DCUNK>
end

end % iMaybeRedistribute
