function D = str2num(S) %#ok<STOUT,INUSD>
%STR2NUM Convert codistributed array of strings to numeric array.
%   X = STR2NUM(S)
%   
%   This function is not supported for codistributed arrays.
%   
%   See also STR2DOUBLE, CODISTRIBUTED.
%   
%   


%   Copyright 2016 The MathWorks, Inc.

error(message('parallel:distributed:Str2numNotSupported'));