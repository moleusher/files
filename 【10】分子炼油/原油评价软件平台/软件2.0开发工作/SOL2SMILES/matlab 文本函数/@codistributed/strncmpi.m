function TF = strncmpi(S1, S2, N)
%STRNCMPI Compare first N characters of codistributed arrays of strings ignoring case.
%   TF = STRNCMPI(S1,S2,N)
%   
%   Note that S1 and S2 must be a single string, a codistributed array of strings
%   or a cell array of char vectors.
%   
%   Example:
%   spmd
%       s1 = { 'Hello', 'Goodbye', 'Farewell', 'Good job' };
%       S1 = codistributed(s1)
%       tf = strncmpi(S1, 'good', 4)
%   end
%   
%   See also STRNCMPI, CODISTRIBUTED/STRCMP, CODISTRIBUTED/STRCMPI, CODISTRIBUTED/STRNCMP, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

narginchk(3, 3);
TF = codistributed.pStrcmpCommon(@strncmpi, S1, S2, N);
