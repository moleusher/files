function P = cummin(varargin)
%CUMMIN Cumulative minimum of elements of codistributed array
%   CUMMIN(X)
%   CUMMIN(X,DIM)
%   CUMMIN(X,DIRECTION)
%   CUMMIN(X,DIM,DIRECTION)
%   
%   Limitations:
%   CUMMIN(___,NANFLAG) is not supported for codistributed array.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = cos(codistributed.linspace(-pi, pi));
%       c = cummin(D);
%       c1 = cummin(D,1);
%       c2 = cummin(D,2);
%       isequal(c1, D)      % true
%       isequal(c, c2)      % true
%   end
%   
%   See also CUMMIN, CODISTRIBUTED, CODISTRIBUTED/LINSPACE.


%   Copyright 2014 The MathWorks, Inc.

initVal = nan;
P = codistributed.pCumop(@cummin,@min,initVal,varargin{:});
