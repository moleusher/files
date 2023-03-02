function c = table2cell(t)
%TABLE2CELL Convert codistributed table to cell array.
%   C = TABLE2CELL(T)
%   
%   See also TABLE2CELL, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

c = codistributed.pElementwiseUnaryOp(@table2cell, t);

end
