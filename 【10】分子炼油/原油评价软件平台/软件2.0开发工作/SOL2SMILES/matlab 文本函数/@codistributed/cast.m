function D2 = cast(D1, varargin)
%CAST Cast a codistributed array to a different data type or class
%   B = CAST(A,NEWCLASS)
%   
%   B = CAST(A, 'like', P) converts A to the same underlying data type as the
%   variable P. If A and P are both real, then B is also real. B is complex
%   otherwise.  B is a codistributed array if and only if A is a codistributed array.
%   If A and P are both dense, then B is also dense.  B is sparse otherwise.
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint32');
%       Ds = cast(Du,'single');
%       classDu = classUnderlying(Du);
%       classDs = classUnderlying(Ds);
%   end
%   
%   casts the codistributed uint32 array Du to the codistributed single array
%   Ds. classDu is 'uint32', while classDs is 'single'.
%   
%   See also CAST, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/CLASSUNDERLYING.


%   Copyright 2006-2015 The MathWorks, Inc.

narginchk(2, 3);

distributedutil.CodistParser.verifyNonCodistributedInputs({D1, varargin});

if nargin == 2
    className = distributedutil.CodistParser.gatherIfCodistributed(varargin{:});
    D2 = iCastClass(D1, className);
    
else
    likeArg = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});
    if ~strcmpi('like', likeArg)
        error(message('MATLAB:cast:invalidSyntax'));
    end
    
    proto = varargin{2};
    D2 = iCastLike(D1, proto);
end
end

function out = iCastClass(in, className)
% Cast only the class of the input
castFcn = @(x)cast(x, className);
if isa(in, 'codistributed')
    % Just cast the local parts
    out = codistributed.pElementwiseUnaryOpWithCatch(castFcn, in); %#ok<DCUNK> private static
else
    % All on host
    out = castFcn(in);
end
end

function out = iCastLike(in, proto)
% Cast the input to match all attributes of the prototype (NB: will gather
% if prototype is not distributed and will distribute if prototype is).
localProto = iCreateLocalPrototype(proto);
resultDistributed = isa(proto, 'codistributed');
inputDistributed = isa(in, 'codistributed');

castFcn = @(x) cast(x, 'like', localProto);

if resultDistributed
    if inputDistributed
        % Both distributed, just convert local parts
        out = codistributed.pElementwiseUnaryOpWithCatch(castFcn, in); %#ok<DCUNK> private static
    else
        % Convert then distribute
        localOut = castFcn(in);
        codistr = proto.Codistributor;
        % If the dimensions match we can use the codistributor directly. If
        % not then we will have to create a new one.
        outSz = size(localOut);
        if ~isequal(codistr.hGetDimensions(), outSz)
            codistr = hGetNewForSize(codistr, outSz);
        end
        out = codistributed(localOut, codistr);
    end
else
    if inputDistributed
        % Input is distributed but prototype isn't. Gather and convert.
        out = castFcn(gather(in));
    else
        % Both on client. We only get here if the 'like' string was
        % distributed but nothing else was. An odd case, but...
        out = castFcn(in);
    end
end

end

function proto = iCreateLocalPrototype(y)
classStr = distributedutil.CodistParser.class(y);
% Cast supports only numeric, char, and logical classes
if ~(distributedutil.CodistParser.isValidNumericOrLogicalType(classStr) || ...
        isequal(classStr, 'char'))
    ME = MException(message('MATLAB:cast:UnsupportedClass',classStr));
    throwAsCaller(ME);
end
fcn = str2func(classStr);

proto = fcn(1);

% It only makes sense to "complexify" a numeric real array or a distributed or
% codistributed array. The latter two classes answer false to 'isnumeric'
% but can be made into complex arrays.
if ~isreal(y) && ...
        (isnumeric(y) || any(strcmp(class(y), {'codistributed','distributed'})))
    proto = complex(proto, proto);
end

% Sparsity only makes sense for numeric arrays.
if issparse(y)
    try
        proto = sparse(proto);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
            ME = MException(message('MATLAB:unimplementedSparseType'));
        end
        throwAsCaller(ME);
    end
end
end
