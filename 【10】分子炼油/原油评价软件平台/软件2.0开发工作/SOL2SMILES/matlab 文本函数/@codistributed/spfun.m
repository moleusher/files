function D = spfun(fun, D)
%SPFUN Apply function to nonzero codistributed matrix elements
%   D2 = SPFUN(FUN,D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.sprand(N, N, 0.2)
%       F = spfun(@exp, D)
%   end
%   
%   F has the same sparsity pattern as D (except for underflow), whereas 
%   EXP(D) has 1's where D has 0's.
%   
%   Note: On each lab, the function FUN only receives as input the nonzero
%   elements of D that are local to that lab.  Therefore, functions that
%   operate element-by-element are the most appropriate for use with
%   SPFUN.
%   
%   See also SPFUN, CODISTRIBUTED, CODISTRIBUTED/SPRAND.


%   Copyright 2006-2016 The MathWorks, Inc.

if ~any(strcmp(class(fun), {'function_handle', 'char'}))
    error(message('parallel:distributed:SpfunInvalidFcn'));
end

if ~isa(D, 'codistributed')
    error(message('parallel:distributed:SpfunInvalidMatrix'));
end

% Input may be full or sparse.  Guard against ND-full input.
if ~ismatrix(D)
    error(message('parallel:distributed:SpfunNDNotSupported'));
end

codistr = getCodistributor(D);
[D, codistr] = ifNotSupportedSparseRedistributeTo1d(D, codistr);
LP = getLocalPart(D);
clear D;

% Apply spfun to all the parts of the array, redistribute if necessary.
sparsifyFcn = @(x) spfun(fun, x);
procFcn = @() codistr.hSparsifyImpl(sparsifyFcn, LP);
% Call hSparsifyImpl with two output arguments, but synchronize the error
% behavior because it is possible that fun throws an error.
[LP, codistr] = distributedutil.syncOnError(procFcn);

D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
