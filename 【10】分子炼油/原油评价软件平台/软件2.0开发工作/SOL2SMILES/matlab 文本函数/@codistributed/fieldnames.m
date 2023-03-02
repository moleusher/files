function names = fieldnames(obj, optArg)
%FIELDNAMES Get structure field names of codistributed array
%   NAMES = FIELDNAMES(S)
%   
%   Example:
%   spmd
%       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
%       names    = {'a','b','c','d','e','f','g','h','i','j'};
%       s = struct('matrix', matrices, 'name', names);
%       S = codistributed(s)
%       f = fieldnames(S)
%   end
%   
%   returns the field names f = {'matrix','name'} of the 1-by-10
%   codistributed array of structs S.
%   
%   See also FIELDNAMES, CODISTRIBUTED.


%   Copyright 2006-2011 The MathWorks, Inc.

if nargin < 2
    optArg = [];
else
    distributedutil.CodistParser.verifyNonCodistributedInputs({obj, optArg});
    optArg = distributedutil.CodistParser.gatherIfCodistributed(optArg);
end

if ~isa(obj, 'codistributed')
    names = fieldnames(obj, optArg);
    return;
end

objDist = getCodistributor(obj);
localObj = getLocalPart(obj);

names = objDist.hFieldnamesImpl(localObj, optArg);


