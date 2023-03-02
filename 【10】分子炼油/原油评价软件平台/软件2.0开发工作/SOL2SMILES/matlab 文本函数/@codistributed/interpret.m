function S = interpret(A)
%INTERPRET Convert escaped characters in string
%   
%   S = INTERPRET(A)
%   
%   See also INTERPRET.
%   


%   Copyright 2016 The MathWorks, Inc.

S = codistributed.pElementwiseUnaryOp(@interpret, A);