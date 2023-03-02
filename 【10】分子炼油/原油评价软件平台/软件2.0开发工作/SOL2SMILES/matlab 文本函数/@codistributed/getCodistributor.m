function dist = getCodistributor(D)
%getCodistributor returns codistributor of a codistributed array
%   DIST = getCodistributor(D) is an object with the distribution information
%   of the codistributed array D.
%   
%   See also CODISTRIBUTOR, CODISTRIBUTOR1D, CODISTRIBUTOR2DBC, 
%   CODISTRIBUTED/GETLOCALPART.


%   Copyright 2009-2011 The MathWorks, Inc.

dist = D.Codistributor;
