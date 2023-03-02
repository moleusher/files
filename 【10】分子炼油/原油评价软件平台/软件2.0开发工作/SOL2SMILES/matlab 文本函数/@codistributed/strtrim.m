function S = strtrim(M)
%STRTRIM Remove leading and trailing whitespace from codistributed array of strings.
%   S = STRTRIM(M)
%   
%   Note that M must be an array of strings or a cell array of char vectors.
%   
%   Example:
%   spmd
%       a = { 'Hello  ',  '  Goodbye' };
%       A = codistributed(a)
%       B = strtrim(A)
%   end
%   
%   See also STRTRIM, CODISTRIBUTED/DEBLANK, CODISTRIBUTED.
%   
%   


%   Copyright 2015-2016 The MathWorks, Inc.

% We only support arrays of strings or cellstr
if ~isStringArray(M)
    error(message('parallel:distributed:NotStringArray', 'STRTRIM'));
end

S = codistributed.pElementwiseUnaryOp(@strtrim, M);
