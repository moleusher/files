function tf = iscategorical(c)
%ISCATEGORICAL True for categorical arrays.
%   
%   TF = ISCATEGORICAL(C)
%    
%   See also ISCATEGORICAL, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = isaUnderlying(c, 'categorical');

