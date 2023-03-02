function tf = isaUnderlying(D, className)
%isaUnderlying    True if the CODISTRIBUTED array's underlying elements are a given class
%   TF = isaUnderlying(D, 'classname') returns true if the elements of D are 
%   either an instance of 'classname' or an instance of a class derived from 
%   'classname'.  isaUnderlying and ISA support the same values for 'classname'. 
%   
%   Example:   
%   spmd
%       N = 1000;
%       D_uint8   = codistributed.ones(1, N, 'uint8');
%       D_cell    = codistributed.cell(1, N);
%       isUint8   = isaUnderlying(D_uint8, 'uint8')   % returns true
%       isInteger = isaUnderlying(D_uint8, 'integer') % returns true
%       isFloat   = isaUnderlying(D_uint8, 'float')   % returns false
%       isDouble  = isaUnderlying(D_cell, 'double')   % returns false
%   end
%   
%   See also ISA, CODISTRIBUTED, CODISTRIBUTED/classUnderlying, CODISTRIBUTED/CELL, CODISTRIBUTED/ONES.
%   

    
%   Copyright 2009-2014 The MathWorks, Inc.
    
narginchk(2, 2);

distributedutil.CodistParser.verifyNonCodistributedInputs({D, className});

dDist = getCodistributor(D);
localD = getLocalPart(D);

tf = dDist.hIsaUnderlyingImpl(localD, className);
    
    
