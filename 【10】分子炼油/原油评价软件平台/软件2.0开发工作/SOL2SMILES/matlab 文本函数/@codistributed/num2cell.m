function a = num2cell(a, dims)
%NUM2CELL Convert numeric codistributed array into cell array
%   C = NUM2CELL(A)
%   C = NUM2CELL(A,DIMS)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)
%       C = num2cell(D)
%       classD = classUnderlying(D)
%       classC = classUnderlying(C)
%   end
%   
%   converts the codistributed double row vector D to the codistributed cell 
%   array C. classD is 'double' while classC is 'cell'.
%   
%   See also NUM2CELL, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/CELL.


%   Copyright 2006-2011 The MathWorks, Inc.

if nargin == 2
    distributedutil.CodistParser.verifyNonCodistributedInputs({a, dims});
    dims = distributedutil.CodistParser.gatherIfCodistributed(dims);
    if ~isa(a, 'codistributed')
        % dims was codistributed, a is not.
        a = num2cell(a, dims);
        return;
    end
end

% At this point, we know that a is codistributed.
codistr = getCodistributor(a);
LP = getLocalPart(a);
clear a;

if nargin == 1
    dims = [];
else
    % Trim the dims vector into the unique values we care about.  
    dims = unique(dims);
    dims = dims(1 <= dims & dims <= length(codistr.Cached.GlobalSize));
end

if isempty(dims)
    % Either no dimension was specified, or they were all outside of 1:ndims.
    [LP, codistr] = codistr.hNum2CellNoDimImpl(LP);
    a = codistributed.pDoBuildFromLocalPart(LP, codistr);  %#ok<DCUNK> private static
    return;
end

if ~codistr.hNum2CellWithDimCheck(LP, dims)
    % We know that codistributor1d supports num2cell with a dimension argument.
    [LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, ...
                                                      codistributor1d());
end

[LP, codistr] = codistr.hNum2CellWithDimImpl(LP, dims);
a = codistributed.pDoBuildFromLocalPart(LP, codistr);  %#ok<DCUNK> private static
end % End of num2cell.
