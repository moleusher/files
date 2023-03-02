function s = cell2struct(c, fields, dim)
%CELL2STRUCT Convert codistributed cell array to structure array
%   S = CELL2STRUCT(C,FIELDS,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       C = codistributed(repmat({rand(7); char(64+7)}, 1, N))
%       f = {'matrix','name'}
%       S = cell2struct(C,f,1)
%       classC = classUnderlying(C)
%       classS = classUnderlying(S)
%   end
%   
%   takes the 2-by-N codistributed cell array c and converts it into a
%   N-by-1 codistributed struct array s, with fields named 'matrix' and
%   'name'.
%   classC is 'cell' while classS is 'struct'.
%   
%   See also CELL2STRUCT, CODISTRIBUTED.


%   Copyright 2006-2012 The MathWorks, Inc.
    
    narginchk(3, 3);
    
    distributedutil.CodistParser.verifyNonCodistributedInputs({c, fields, dim});
    
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    fields = distributedutil.CodistParser.gatherIfCodistributed(fields);
    
    if ~isa(c, 'codistributed')
        %If only the other arguments were distributed, we can now call the
        %regular function.
        s = cell2struct(c, fields, dim);
        return;
    end
        
    codistr = getCodistributor(c);
    LP = getLocalPart(c);
    
    if size(c, dim) ~= numel(fields)
        error(message('parallel:distributed:Cell2StructInvalidFieldSize'));
    end
    
    if ~codistr.hIsaUnderlyingImpl(LP, 'cell')
        error(message('parallel:distributed:Cell2StructInvalidInputType'));
    end
        
    [LP, codistr] = codistr.hCell2StructImpl(LP, fields, dim);
     
    s = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
        
end % End of cell2struct.
