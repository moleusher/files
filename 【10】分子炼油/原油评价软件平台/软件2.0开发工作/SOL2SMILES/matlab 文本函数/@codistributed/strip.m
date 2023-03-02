function S = strip(STR, varargin)
%STRIP Remove leading and trailing characters.
%   S = STRIP(M)
%   S = STRIP(M, SIDE)
%   S = STRIP(M, SIDE, StripCharacter)
%   
%   See also STRIP, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(1, 3);
S = codistributed.pElementwiseUnaryOp(@strip, STR, varargin{:});
