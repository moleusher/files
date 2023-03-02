function D = empty(varargin)
%CODISTRIBUTED.EMPTY Create empty array of class CODISTRIBUTED
%   A = CODISTRIBUTED.EMPTY returns an empty 0-by-0 CODISTRIBUTED.
%   
%   A = CODISTRIBUTED.EMPTY(M,N,P,...) returns an empty CODISTRIBUTED of doubles
%   with the specified dimensions. At least one of the dimensions must be 0.
%   
%   A = CODISTRIBUTED.EMPTY([M,N,P,...]) returns an empty CODISTRIBUTED of doubles 
%   with the specified dimensions. At least one of the dimensions must be 0.
%   
%   A = CODISTRIBUTED.EMPTY(...,CLASSNAME) returns an empty CODISTRIBUTED with 
%   the specified dimensions and underlying type.
%   
%   Other optional arguments to CODISTRIBUTED.EMPTY must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Examples:
%   spmd
%       A = codistributed.empty                 % 0-by-0 codistributed matrix
%       B = codistributed.empty(0,3)            % 0-by-3 codistributed matrix
%       C = codistributed.empty([2,0,4],'int8') % underlying class 'int8'
%       % 0-by-0 codistributed array, distributed by the first 
%       % dimension (rows):
%       D = codistributed.empty(codistributor('1d', 1))
%       % Underlying class 'single, using 2D block-cyclic codistributor.
%       E = codistributed.empty('single', codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/BUILD,
%   CODISTRIBUTOR.


%   Copyright 2012-2014 The MathWorks, Inc.

    try
        argList = iValidateInputArguments(varargin{:});
    catch ME
        throw(ME);
    end
    
    D = codistributed.pBuildFromFcn(@zeros, argList{:}); %#ok<DCUNK>
end

function argList = iValidateInputArguments(varargin)
    allowNegativeSizes = true;
    [sizeVec, className, codistr, allowCommunication] = ...
        codistributed.pParseBuildArgs('empty', allowNegativeSizes, varargin); %#ok<DCUNK>

    if prod(sizeVec) ~= 0
        error(message('MATLAB:class:emptyMustBeZero'));
    end

    % Use the default class if one was not requested.
    if isempty(className)
        className = 'double';
    end

    % Reconstruct the argument list now that we have valid
    % size and class specifications.
    argList =  [{sizeVec}, {className}, {codistr}];
    if ~allowCommunication
        argList = [ argList, {'noCommunication'}];
    end
end
