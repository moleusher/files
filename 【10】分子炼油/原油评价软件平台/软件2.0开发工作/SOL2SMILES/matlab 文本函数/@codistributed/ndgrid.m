function varargout = ndgrid(varargin)
%NDGRID Generate codistributed arrays for N-D functions and interpolation.
%   [X1,X2,X3,...] = NDGRID(x1,x2,x3,...) 
%   [X1,X2,...] = NDGRID(x) is the same as [X1,X2,...] = NDGRID(x,x,...)
%       
%   NDGRID for codistributed arrays supports the same syntax as the builtin, with one 
%   notable exception.  In the 1-D case, X = NDGRID(x) returns a codistributed array 
%   column vector X that contains the elements of the input codistributed array x for 
%   use as a one-dimensional grid.
%   
%   Class support for inputs:
%          float: double, single
%   
%   Example:
%   spmd
%            N = 1000;
%            x = codistributed.ones(N, 1);
%            y = codistributed.rand(2*N,1);
%            [X, Y] = ndgrid(x, y);
%   end
%   
%   See also NDGRID, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2010-2012 The MathWorks, Inc.

narginchk(1, Inf);
nargoutchk(0, Inf);

% Check that there are enough inputs to support the outputs
if (nargin > 1) && (nargin < nargout)
    error(message('parallel:distributed:NdgridNotEnoughInputs'));
end

isInputFloat = cellfun(@(x)distributedutil.CodistParser.isa(x, 'float'), ...
                       varargin);
if ~all(isInputFloat)
    error(message('parallel:distributed:NdgridOnlySupportFloat'));
end

numDim = max(nargout, 2);

% Replicate a single input
if nargin == 1
    if nargout <= 1
        varargout{1} = full(reshape(varargin{1}, [numel(varargin{1}), 1]));
        return
    else
        varargin = repmat(varargin, 1, numDim);
    end
end

numInputs = length(varargin);

% Determine codistributor
codistr = iDetermineCodistributor( varargin, numInputs );
if isa(codistr, 'codistributor1d') && codistr.Dimension > numInputs
    varargin((numInputs+1):codistr.Dimension) = num2cell(ones(1, ...
                                    codistr.Dimension - numInputs));
end

% Check for empty inputs
isInputEmpty = any(cellfun(@isempty, varargin));

numOut = max(1, nargout);
varargout = cell(1, numOut);
% Produce empty outputs if any input was empty
if isInputEmpty
    sizes = cellfun(@numel, varargin);
    codistr = codistr.hGetNewForSize(sizes);
    for i = 1:numOut
        varargout{i} = codistributed.zeros(sizes, ...
                          distributedutil.CodistParser.class(varargin{i}), ...
                                            codistr );
    end
    return
end

% Produce cell array for input to implementation
cellOfReplicated = cellfun(@distributedutil.CodistParser.gatherIfCodistributed, ...
                           varargin, 'UniformOutput', false);

% Do the calculation
[codistr, cellOfLPs] = codistr.hNDGridImpl(cellOfReplicated, numOut);

% Build the outputs
for i = 1:numOut
    varargout{i} = codistributed.pDoBuildFromLocalPart(cellOfLPs{i}, codistr); %#ok<DCUNK>
end

end  %ndgrid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function codistr = iDetermineCodistributor( cellOfInputs, numOutputDims )
    isInputCodistributed = cellfun(@iscodistributed, cellOfInputs);
    
    codistr = getCodistributor( cellOfInputs{ find(isInputCodistributed, 1) } );
    compareCodistrs = @(x)strcmp( class(getCodistributor(x)), class(codistr) );
    doCodistributorsAgree = cellfun( compareCodistrs, ...
        cellOfInputs( isInputCodistributed ) );
    
    useFirstCodistr = all( doCodistributorsAgree ) && ...
                           codistr.hSupportsDimensionality( numOutputDims );
                           
    if ~useFirstCodistr
        codistr = codistributor1d();
    end
end
