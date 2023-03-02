function varargout = min(varargin)
%MIN Smallest component of codistributed array
%   Y = MIN(X)
%   [Y,I] = MIN(X)
%   [Y,I] = MIN(X,[],DIM)
%   Z = MIN(X,Y)
%   MIN(...,'omitnan')
%   MIN(...,'includenan')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed(magic(N))
%       m = min(D)
%       m1 = min(D,[],1)
%       m2 = min(D,[],2,'omitnan')
%   end
%   
%   m and m1 are both codistributed row vectors, m2 is a codistributed column 
%   vector.
%   
%   See also MIN, CODISTRIBUTED, MAGIC.
%   


%   Copyright 2006-2016 The MathWorks, Inc.

[varargout{1:nargout}] = minmaxOp(@min,varargin{:});
