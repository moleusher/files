function TF = strcmp(S1, S2)
%STRCMP Compare codistributed arrays of strings.
%   TF = STRCMP(S1,S2)
%   
%   Note that S1 and S2 must be a single string, a codistributed array of strings
%   or a cell array of char vectors.
%   
%   Example:
%   spmd
%       s1 = { 'Hello', 'Goodbye', 'Farewell', 'Good job' };
%       S1 = codistributed(s1)
%       tf = strcmp(S1, 'Goodbye')
%   end
%   
%   See also STRCMP, CODISTRIBUTED/STRCMPI, CODISTRIBUTED/STRNCMP, CODISTRIBUTED/STRNCMPI, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

narginchk(2, 2);
TF = codistributed.pStrcmpCommon(@strcmp, S1, S2);
