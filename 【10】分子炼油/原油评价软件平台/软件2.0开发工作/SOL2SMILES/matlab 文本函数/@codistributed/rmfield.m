function t = rmfield(s,field)
%RMFIELD Remove fields from a structure codistributed array
%   S = RMFIELD(S,'field')
%   S = RMFIELD(S,FIELDS)
%   
%   Example:
%   spmd
%       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
%       names    = {'a','b','c','d','e','f','g','h','i','j'};
%       s = struct('matrix', matrices, 'name', names);
%       S = codistributed(s)
%       S = rmfield(S,'name')
%       classS = classUnderlying(S)
%   end
%   
%   removes the field named 'name' from the codistributed array of structs S.
%   classS is 'struct'.
%   
%   See also RMFIELD, CODISTRIBUTED.


%   Copyright 2006-2012 The MathWorks, Inc.

narginchk(2, 2);
distributedutil.CodistParser.verifyNonCodistributedInputs({s, field});

if isa(field, 'codistributed')
    t = rmfield(s, gather(field));
elseif isa(s, 'codistributed')
    t = codistributed.pElementwiseUnaryOp(@(x) (rmfield(x, field)), s); %#ok<DCUNK>
end
