function out = typecast(in, datatype)
%TYPECAST Convert datatypes of codistributed array without changing underlying data
%   Y = TYPECAST(X, DATATYPE)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = -1*codistributed.ones(1,N,'int8');
%       Du = typecast(Di,'uint8')
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   type casts the 1-by-N codistributed uint8 row vector Du to the
%   codistributed int8 array Di.
%   Di has all values -1 while Du has all values 255.
%   classDi is 'int8' while classDu is 'uint8'.
%   
%   See also TYPECAST, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/CLASSUNDERLYING.
%   


%   Copyright 2006-2013 The MathWorks, Inc.

narginchk(2, 2)

datatype = distributedutil.CodistParser.gatherIfCodistributed(datatype);
if ~isa(in, 'codistributed')
    out = typecast(in,datatype);
    return;
end

% Error out right away if datatype or input array is not valid for typecast.
if ~distributedutil.CodistParser.isValidTypecastDataType(datatype) || ...
        ~distributedutil.CodistParser.isValidTypecastDataType(...
            distributedutil.CodistParser.class(in))
    error(message('parallel:distributed:TypecastUnsupportedClass'));
end

% Error out right away if the first argument is not a vector.
% I can't rely on the native typecast to handle this because some or all of
% the local arrays may be vectors
if ~isvector(in) && ~isempty(in)
    error(message('parallel:distributed:TypecastFirstArgMustBeVector'));
end

% Error out if the first argument is complex. Codistributed typecast does
% not support the complex datatype.
if ~isreal(in)
    error(message('parallel:distributed:TypecastFirstArgMustBeReal'));
end

codistr = getCodistributor(in);
LP = getLocalPart(in);

[LP, codistr] = codistr.hTypecastImpl(LP, datatype);

out = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>




