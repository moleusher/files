function TF = strcmpi(S1, S2)
%STRCMPI Compare codistributed arrays of strings ignoring case.
%   TF = STRCMPI(S1,S2)
%   
%   Note that S1 and S2 must be a single string, a codistributed array of strings
%   or a cell array of char vectors.
%   
%   Example:
%   spmd
%       s1 = { 'Hello', 'Goodbye', 'Farewell', 'Good job' };
%       S1 = codistributed(s1)
%       tf = strcmpi(S1, 'goodbye')
%   end
%   
%   See also STRCMP, CODISTRIBUTED/STRCMP, CODISTRIBUTED/STRNCMP, CODISTRIBUTED/STRNCMPI, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

narginchk(2, 2);
TF = codistributed.pStrcmpCommon(@strcmpi, S1, S2);
