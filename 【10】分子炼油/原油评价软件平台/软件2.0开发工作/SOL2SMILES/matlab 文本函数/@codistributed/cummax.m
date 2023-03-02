function P = cummax(varargin)
%CUMMAX Cumulative maximum of elements of codistributed array
%   CUMMAX(X)
%   CUMMAX(X,DIM)
%   CUMMAX(X,DIRECTION)
%   CUMMAX(X,DIM,DIRECTION)
%   
%   Limitations:
%   CUMMAX(___,NANFLAG) is not supported for codistributed array.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = cos(codistributed.linspace(-pi, pi));
%       c = cummax(D);
%       c1 = cummax(D,1);
%       c2 = cummax(D,2);
%       isequal(c1, D)     % true
%       isequal(c, c2)     % true
%   end
%   
%   See also CUMMAX, CODISTRIBUTED, CODISTRIBUTED/LINSPACE.


%   Copyright 2014 The MathWorks, Inc.

initVal = nan;
P = codistributed.pCumop(@cummax,@max,initVal,varargin{:});
