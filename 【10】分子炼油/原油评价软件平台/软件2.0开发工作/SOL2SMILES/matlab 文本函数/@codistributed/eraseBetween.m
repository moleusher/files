function s = eraseBetween(str,startStr,endStr,varargin)
%ERASEBETWEEN Remove segments from string elements.
%   STR = ERASEBETWEEN(STR, START, END)
%   
%   See also ERASEBETWEEN, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(3, 3);

% Trap bad inputs even if empty
if ~isstring(str) && ~ischar(str) && ~iscellstr(str)
    firstInput = getString(message('MATLAB:string:FirstInput'));
    error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
end

if isempty(str)
    s = str;
    return;
end

% Make sure we treat char arrays as scalars
startStr = wrapCharInput(startStr);
endStr = wrapCharInput(endStr);

s = codistributed.pElementwiseOp(@(a,b,c) eraseBetween(a,b,c,varargin{:}), ...
    str, startStr, endStr);
end

function x = wrapCharInput(x)
% Helper to wrap char inputs in scalar string so that dimension expansion
% rules are honoured.
if ischar(x)
    if ~isrow(x) && ~isempty(x)
        error(message('MATLAB:string:PositionMustBeTextOrNumeric'));
    end
    x = string(x);
end
end
