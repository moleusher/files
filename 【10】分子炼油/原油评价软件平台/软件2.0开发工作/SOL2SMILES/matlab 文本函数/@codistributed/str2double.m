function D = str2double(S)
%STR2DOUBLE Convert codistributed array of strings to double precision values.
%   X = STR2DOUBLE(S)
%   
%   Note that S must be an array of strings or a cell array of char vectors.
%   
%   Example:
%   spmd
%       s = { '1.1',  '2.2',  '3.3',  'nan' };
%       S = codistributed(s)
%       C = str2double(S)
%   end
%   
%   See also STR2DOUBLE, CODISTRIBUTED.
%   
%   


%   Copyright 2015-2016 The MathWorks, Inc.

% We only support arrays of strings (cellstr)
if ~isStringArray(S)
    error(message('parallel:distributed:NotStringArray', 'STR2DOUBLE'));
end

D = codistributed.pElementwiseUnaryOp(@str2double, S);
