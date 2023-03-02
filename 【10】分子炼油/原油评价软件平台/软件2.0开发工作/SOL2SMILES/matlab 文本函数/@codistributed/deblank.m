function R = deblank(S)
%DEBLANK Remove trailing blanks from codistributed array of strings.
%   R = DEBLANK(S)
%   
%   Note that S must be an array of strings or a cell array of char vectors.
%   
%   Example:
%   spmd
%       a = { 'Hello  ',  'Goodbye ' };
%       A = codistributed(a)
%       B = deblank(A)
%   end
%   
%   See also DEBLANK, CODISTRIBUTED/STRTRIM, CODISTRIBUTED.
%   
%   


%   Copyright 2015-2016 The MathWorks, Inc.

% We only support arrays of strings or cellstr
if ~isStringArray(S)
    error(message('parallel:distributed:NotStringArray', 'DEBLANK'));
end

R = codistributed.pElementwiseUnaryOp(@deblank, S);
