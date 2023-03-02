function varargout = pElementwiseUnaryOp(fcn, data, varargin)
%Call a unary element-wise function. 
%   
%   D2 = codistributed.pElementwiseUnaryOp(F, D1, ...) performs the elementwise 
%   unary operation F on all elements of D1. Trailing arguments are gathered to 
%   the client. If D1 is not codistributed then the function is run on the client 
%   instead.
%   


%   Copyright 2007-2016 The MathWorks, Inc.

narginchk(2, inf);
out = cell(1,nargout);

% Only first input should be distributed. Gather the rest and call on
% client if none still distributed.
distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);
varargin = distributedutil.CodistParser.gatherElements(varargin);
if ~isa(data, 'codistributed')
    % Only the optional arguments were codistributed. Redirect to client
    % function.
    [out{:}] = fcn(data, varargin{:});
    varargout = out;
    return;
end

% Call the op on the local part. 
LP = getLocalPart(data);
codistr = getCodistributor(data);
out = cell(1,nargout);
try
    % Operate on the local part. All outputs will have same size as input.
    [out{:}] = fcn(LP, varargin{:});
catch E
    throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
end

% Package all outputs back into codistributed
varargout = cellfun(@(lp) pDoBuildFromLocalPart(lp, codistr), out, ...
    'UniformOutput', false);
