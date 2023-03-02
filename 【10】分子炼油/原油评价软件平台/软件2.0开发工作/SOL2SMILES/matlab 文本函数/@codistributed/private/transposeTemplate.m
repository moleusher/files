function A = transposeTemplate(A, transposeFcn)
% TRANSPOSETEMPLATE Template for TRANSPOSE and CTRANSPOSE
% transposeFcn is either @transpose or @ctranspose

%   Copyright 2009-2016 The MathWorks, Inc.
 
    if ~ismatrix(A)
        ME = MException(message('parallel:distributed:TransposeMatrixOnly', ...
                                upper(func2str(transposeFcn))));
        throwAsCaller(ME)
    end

    codistr = getCodistributor(A);
    LP = getLocalPart(A);

    [LP, codistr] = codistr.hTransposeTemplateImpl(LP, transposeFcn); 

    A = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end




