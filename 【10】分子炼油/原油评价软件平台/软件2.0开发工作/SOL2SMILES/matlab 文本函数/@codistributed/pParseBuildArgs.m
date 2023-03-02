function [sizeVec, className, codistr, allowCommunication, limits] = ...
    pParseBuildArgs(fcnName, allowNegativeSizes, argList, extractCodistrFcn)
; %#ok<NOSEM> % Undocumented
%pParseBuildArgs Parse input arguments to codistributed build functions
%   This is the generalization of all of the "build" function argument parsing:
%   ones, zeros, cell, true, false, nan, inf, eye.
%   
%   Expected input: pParseArgs(szs [, className] [,codistr] [,'noCommunication'])
%   where szs is either a comma separated list of sizes, or a vector of sizes.    
%   
%   sizeVec is returned as a vector of length >= 2 containing integer-valued scalars.
%   className is either the empty string, or the specified value


%   Copyright 2009-2016 The MathWorks, Inc.

if ~ischar(fcnName) || ~iscell(argList)
    error(message('parallel:distributed:ParseBuildArgsInvalidInput'));
end

distributedutil.CodistParser.verifyNonCodistributedInputs(argList);

% default function for extracting codistributor from argList
if nargin < 4
    extractCodistrFcn = @distributedutil.CodistParser.extractCodistributor;
end

[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = extractCodistrFcn(argList);
if allowCommunication
    % Ensure that we can handle class name being codistributed.
    argList = distributedutil.CodistParser.gatherElements(argList);
else
    distributedutil.CodistParser.verifyNotCodistWithNoComm(fcnName, argList);    
end

% For RANDI, strip off the limits argument
limits = [];
if strcmpi(fcnName, 'randi') && numel(argList)>0
    limits = argList{1};
    argList(1) = [];
end

if length(argList) >= 1 && ischar(argList{end}) 
    className = argList{end};
    sizesD = argList(1:end - 1);
else
    className = '';
    sizesD = argList;
end

sizeVec = distributedutil.CodistParser.parseArraySizes(sizesD, fcnName, allowNegativeSizes);

if allowCommunication
    argsToCheck = {limits, sizeVec, className, codistr};
    distributedutil.CodistParser.verifyReplicatedInputArgs(fcnName, argsToCheck);
end

end % End of pParseBuildArgs.
