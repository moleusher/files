function varargout = max(varargin)
%MAX Largest component of codistributed array
%   Y = MAX(X)
%   [Y,I] = MAX(X)
%   [Y,I] = MAX(X,[],DIM)
%   Z = MAX(X,Y)
%   MAX(...,'omitnan')
%   MAX(...,'includenan')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed(magic(N))
%       m = max(D)
%       m1 = max(D,[],1)
%       m2 = max(D,[],2,'omitnan')
%   end
%   
%   m and m1 are both codistributed row vectors, m2 is a codistributed column 
%   vector.
%   
%   See also MAX, CODISTRIBUTED, MAGIC.
%   


%   Copyright 2006-2016 The MathWorks, Inc.

[varargout{1:nargout}] = minmaxOp(@max,varargin{:});
