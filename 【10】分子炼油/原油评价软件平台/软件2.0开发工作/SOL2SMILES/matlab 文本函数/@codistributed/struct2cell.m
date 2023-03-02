function c = struct2cell(s)
%STRUCT2CELL Convert structure codistributed array to cell codistributed array
%   C = STRUCT2CELL(S)
%   
%   If the original struct array is distributed along dimension DIM, the
%   resulting cell array will be distributed along dimension DIM+1.
%   
%   Example:
%   spmd
%       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
%       names    = {'a','b','c','d','e','f','g','h','i','j'};
%       s = struct('matrix', matrices, 'name', names);
%       S = codistributed(s)
%       C = struct2cell(S)
%       classS = classUnderlying(S)
%       classC = classUnderlying(C)
%   end
%   
%   converts the 1-by-10 codistributed array of structs S to the
%   2-by-1-by-10 codistributed cell array C.
%   classS is 'struct' while classC is 'cell'.
%   
%   See also STRUCT2CELL, CODISTRIBUTED.


%   Copyright 2006-2012 The MathWorks, Inc.


    
% struct2cell implementation only supports codistributor1d. Codistributor2dbc
% is converted and redistributed to codistributor1d.
    
    codistr = getCodistributor(s);
    LP = getLocalPart(s);
    
    if ~codistr.hIsaUnderlyingImpl(LP, 'struct')
        error(message('parallel:distributed:Struct2CellInvalidInputType'));
    end
    
    if ~codistr.hSupportsStruct2Cell()
        [LP, codistr] = iConvertTo1DDistribution(LP, codistr);
    end
    
    [LP, codistr] = codistr.hStruct2CellImpl(LP);
    c = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end

function [LP, codistr] = iConvertTo1DDistribution(LP, codistr)
    destCodistr = codistributor1d(codistributor1d.unsetDimension, ...
                                  codistributor1d.unsetPartition, ...
                                  codistr.Cached.GlobalSize); 
    [LP, codistr] = distributedutil.Redistributor.redistribute(...
        codistr, LP, destCodistr);
end
