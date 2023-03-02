function im = ismissing(t, varargin)
%ISMISSING Find elements in a codistributed table that contain missing values.
%   I = ISMISSING(T)
%   I = ISMISSING(T,INDICATORS)
%   
%   See also ISMISSING, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

im = codistributed.pElementwiseUnaryOp(@ismissing, t, varargin{:});

end
