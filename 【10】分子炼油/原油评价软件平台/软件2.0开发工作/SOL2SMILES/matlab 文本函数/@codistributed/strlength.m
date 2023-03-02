function L = strlength(S)
%STRLENGTH Lengths of string elements
%   
%   L = STRLENGTH(S)
%   
%   See also STRLENGTH.
%   


%   Copyright 2016 The MathWorks, Inc.

if isaUnderlying(S, 'cell')
    % Workers can throw if they hit a cell that doesn't contain text, so
    % we must sync on error.
    L = codistributed.pElementwiseUnaryOpWithCatch(@strlength, S);
else
    L = codistributed.pElementwiseUnaryOp(@strlength, S);
end
