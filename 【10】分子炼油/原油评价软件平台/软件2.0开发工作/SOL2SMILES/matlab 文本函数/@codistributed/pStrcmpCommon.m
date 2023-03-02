function TF = pStrcmpCommon(fcn, S1, S2, varargin)
%pStrcmpCommon Common logic for all codistributed STRCMP functions
%   Y = codistributed.pStrcmpCommon(FCN, S1, S2, ...) performs some input
%   checking and then calls FCN in an element-wise sense with the relevant arguments.
%   


%   Copyright 2015-2016 The MathWorks, Inc.

% We will use the standard element-wise helper to run the operation. This
% requires that both S1 and S2 are string arrays or cellstr so that the
% size comparison will work.
S1 = checkInput(S1, func2str(fcn));
S2 = checkInput(S2, func2str(fcn));

TF = codistributed.pElementwiseOp(fcn, S1, S2, varargin{:});
end


function S = checkInput(S, fcnName)
% Check an input is supported and is an array of strings or cellstr

if iscodistributed(S)
    % We only support arrays of strings (or cellstr) for distributed inputs
    if ~isStringArray(S)
        error(message('parallel:distributed:NotStringArray', upper(fcnName)));
    end
else
    % Non-distributed inputs should be cells for the elementwise helper
    if ischar(S)
        % ... and char inputs must be row vectors (or '')
        if ~isequal(S, '') && ~isrow(S)
            error(message('MATLAB:bigdata:array:CharArrayNotRow', upper(fcnName)));
        end
        S = string(S);
    end
end
end
