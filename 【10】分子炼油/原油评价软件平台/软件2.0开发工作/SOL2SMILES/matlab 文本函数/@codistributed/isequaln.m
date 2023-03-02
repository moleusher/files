function flag = isequaln(varargin)
%ISEQUALN True if codistributed arrays are numerically equal
%   TF = ISEQUALN(A,B)
%   TF = ISEQUALN(A,B,C,...)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.nan(N);
%       f = isequal(D,D)
%       t = isequaln(D,D)
%   end
%   
%   returns f = false and t = true.
%   
%   See also ISEQUALN, CODISTRIBUTED, CODISTRIBUTED/NAN.
%   


%   Copyright 2006-2016 The MathWorks, Inc.

flag = isequalTemplate(@isequaln,varargin{:});
