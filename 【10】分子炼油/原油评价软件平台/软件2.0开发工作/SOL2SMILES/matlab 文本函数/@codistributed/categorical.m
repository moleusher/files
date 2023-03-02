function c = categorical(data, varargin)
%CATEGORICAL Create a codistributed array of CATEGORICALs.
%   C = CATEGORICAL(DATA)
%   C = CATEGORICAL(DATA,VALUESET)
%   C = CATEGORICAL(DATA,VALUESET,CATEGORYNAMES)
%   C = CATEGORICAL(DATA, ..., 'Ordinal',ORD)
%   C = CATEGORICAL(DATA, ..., 'Protected',PROTECT)
%    
%   LIMITATION:
%   The order of the categories when executing C = categorical(DATA) is
%   undefined. Use VALUESET and CATEGORYNAMES to enforce the order
%   
%   See also: CATEGORICAL, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(1,7);

% Take care over char data as it can get confused with options
if ischar(data)
    error(message('MATLAB:categorical:CharData'));
end

% Constructing from an existing categorical can be done directly on 
% the local parts and acts element-wise.
if iscategorical(data)
    c = codistributed.pElementwiseUnaryOp(@categorical, data, varargin{:});
    return;
end

if nargin == 1 || iIsUsingOrdinalOrProtected(varargin{1})
    % To get the right category order we need to find the ordered unique
    % values.
    lp = getLocalPart(data);
    
    % Not all types support unique, so take care to throw the right error
    try
        localVals = unique(lp(:));
        valSet = gop( @(x,y) unique([x(:);y(:)]), localVals );
    catch ME
        m = message('MATLAB:categorical:UniqueMethodFailedData');
        throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
    end
    
    % Remove any empty strings
    valSet = iRemoveEmptyStrings(valSet);

    % Apply value order to all local parts
    c = codistributed.pElementwiseUnaryOp(@categorical, data, valSet, varargin{:});
else
    % Just run as unary element-wise (will broadcast trailing arguments)
    c = codistributed.pElementwiseUnaryOp(@categorical, data, varargin{:});
end
end

function tf = iIsUsingOrdinalOrProtected(flag)
% Check for ordinal or protected flags
tf = iIsScalarString(flag) ...
    && (strcmpi('Ordinal', flag) || strcmpi('Protected', flag));
end

function tf = iIsScalarString(s)
% Check that we have a char row or scalar string.
tf = (ischar(s) && isrow(s)) || (isstring(s) && isscalar(s));
end

function vals = iRemoveEmptyStrings(vals)
% Check that we don't try to set categories with empty names
if iscellstr(vals)
    vals(cellfun(@isempty, vals)) = [];
elseif isstring(vals)
    vals(strlength(vals)==0) = [];
end
end
