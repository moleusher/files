function R = pSumAndProd(fcn, A, argList)
%pSumAndProd is a common implementation of sum and prod for (co)distributed 
%   matrices
%   


%   Copyright 2012-2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs({A, argList});
argList = distributedutil.CodistParser.gatherElements(argList);
if ~isa(A, 'codistributed')
    % Dimension or accumType are codistributed, but not the array itself.
    try
        R = fcn(A, argList{:});
        return;
    catch E
        throwAsCaller(E);
    end
end

try
    [argList, trailingArgs] = iGetTrailingArgs(fcn, argList);
    
    % Forward trailing args to sum or prod, then reduce.
    accumFcn = @(varargin) fcn(varargin{:}, trailingArgs{:});
    R = codistributed.pReductionOpAlongDim(accumFcn, A, argList{:});
    
catch E
    throwAsCaller(E); % Strip ourselves from the stack.
    
end
end


function [argList, trailingArgs] = iGetTrailingArgs(fcn, argList)
% Helper to split data and dimension args from trailing flags
% Unlike the other reduction functions (any, all), sum and prod take extra
% string arguments that control the type and missing value handling.  We peel
% those off and hide them from our generic reduction processing.
idx = find(~cellfun(@ischar, argList), 1, 'last');
if isempty(idx)
    % No non-char args
    trailingArgs = argList;
    argList = {};
else
    % Strip trailing args
    trailingArgs = argList(idx+1:end);
    argList = argList(1:idx);
end

% If more than one trailing arg (i.e. more than just dim) we have a
% problem.
if numel(argList) > 1
    error(message(['MATLAB:',func2str(fcn),':unknownFlag']));
end
end
