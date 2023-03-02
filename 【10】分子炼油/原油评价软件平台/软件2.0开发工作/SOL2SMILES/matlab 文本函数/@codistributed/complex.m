function C = complex(A,B)
%COMPLEX Construct complex codistributed array from real and imaginary parts
%   C = COMPLEX(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 3*codistributed.ones(N);
%       D2 = 4*codistributed.ones(N);
%       E = complex(D1,D2)
%   end
%   
%   See also COMPLEX, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

% If only one input and it's already complex there's nothing to do.
if nargin == 1 && ~isreal(A)
    C = A;
    return;
end

if nargin == 2
    distributedutil.CodistParser.verifyNonCodistributedInputs({A, B});
end

if ~isValidInputForComplex(A) || (nargin > 1 && ~isValidInputForComplex(B))
    error(message('parallel:distributed:ComplexInput'));
end

if nargin == 1
    C = codistributed.pElementwiseUnaryOp(@complex, A); %#ok<DCUNK>
else
    C = codistributed.pElementwiseOp(@complex, A, B); %#ok<DCUNK>
end

%%%subfunction

function flag = isValidInputForComplex(A)
%   Check if A is a valid input for COMPLEX
flag = isreal(A) && ~issparse(A); % && isnumeric(A);
