function out = summary(t)
%SUMMARY Print summary of a  codistributed table.
%   SUMMARY(T)
%   
%   See also TABLE/SUMMARY, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

if ~istable(t)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(t)));
end

summaryInfo = distributedutil.calculateSummary(t);
tableProps  = subsref(t, substruct('.', 'Properties' ));
% Only lab 1 prints the result
if labindex==1 && nargout == 0
    matlab.bigdata.internal.util.printSummary(summaryInfo, ...
                                              tableProps);
elseif nargout > 0
    out = matlab.bigdata.internal.util.emitSummary(summaryInfo, ...
                                                   tableProps);
end
end
