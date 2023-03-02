function TF = strncmp(S1, S2, N)
%STRNCMP Compare first N characters of codistributed arrays of strings.
%   TF = STRNCMP(S1,S2,N)
%   
%   Note that S1 and S2 must be a single string, a codistributed array of strings
%   or a cell array of char vectors.
%   
%   Example:
%   spmd
%       s1 = { 'Hello', 'Goodbye', 'Farewell', 'Good job' };
%       S1 = codistributed(s1)
%       tf = strncmp(S1, 'Good', 4)
%   end
%   
%   See also STRNCMPI, CODISTRIBUTED/STRCMP, CODISTRIBUTED/STRNCMP, CODISTRIBUTED/STRNCMPI, CODISTRIBUTED.
%   
%   


%   Copyright 2015 The MathWorks, Inc.

narginchk(3, 3);
TF = codistributed.pStrcmpCommon(@strncmp, S1, S2, N);
