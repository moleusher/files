function varargout = cellfun(varargin)
%CELLFUN Apply a function to each cell of a codistributed cell array
%   A = CELLFUN(FUN, C)
%   A = CELLFUN(FUN, B, C, ...)
%   [A, B, ...] = CELLFUN(FUN, C,  ..., 'Param1', val1, ...)
%   
%   Example:
%   spmd
%       N = 1000;
%       C = codistributed.cell(N)
%       T = cellfun(@isempty,C)
%       classC = classUnderlying(C)
%       classT = classUnderlying(T)
%   end
%   
%   returns a N-by-N codistributed logical matrix T the same as
%   codistributed.true(N).
%   classC is 'cell' while classT is 'logical'.
%   
%   See also  CELLFUN, CODISTRIBUTED, CODISTRIBUTED/CELL.


%   Copyright 2006-2012 The MathWorks, Inc.

narginchk(2, Inf);
isCellfun = true;
[varargout{1:max(1, nargout)}] = codistributed.pCellfunAndArrayfun(...
    isCellfun, varargin); %#ok<DCUNK>

end % End of cellfun.
