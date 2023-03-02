function [C,m] = convDistRepl(A,B,convFcnHandle,outClass,isResultRow)
% Perform convolution of distributed array (A) with replicated array (B)
% with the appropriate shape. isResultRow is an optional parameter used by
% conv (1D convolution) to return a result with the right shape

% Copyright 2016 The MathWorks, Inc.

codistrA = getCodistributor(A);
partA = codistrA.Partition;

% Find the first and last workers that actually contain data
startLab = find(partA > 0,1,'first');
endLab = find(partA > 0,1,'last');

lpA = getLocalPart(A);

if isstruct(B)
    % Separated vectors hrow, hcol
    szB = [numel(B.hrow), numel(B.hcol)];
    paddingGsize = [];
else
    % Matrix B (if A has got higher dimensionality extend B)
    szB = [size(B) ones(1,ndims(A) - ndims(B))];
    paddingGsize = ones(1,ndims(B) - ndims(A));
end

isConv = isequal(convFcnHandle, @conv);

% If we are doing a 1D convolution, make sure B has the same shape
% of A (B is not distributed at this stage)
if isConv
    assert(nargin==5);
    assert(~isstruct(B));
    if all(size(A) ~= size(B))
        B = B.';
        szB = flip(szB);
    end
end

% Global size
gSize = codistrA.Cached.GlobalSize;
gSize = [gSize paddingGsize] + max(szB - 1,0);

% Parts assigned to each lab
part = codistrA.Partition;

% Scalar quantities
dim = codistrA.Dimension;
maxSend = szB(dim) - 1;

if part(labindex) ~= 0
    receiveStages = convReceiveStages(labindex,startLab,part,maxSend);
    [sendStages, sendQty] = convSendStages(labindex,endLab,part,maxSend);

    % Track how much of the output to keep. All labs except the end one
    % keep one slice of data for every slice they have before padding. The
    % final lab must keep the trailing result.
    startIdx = 0;
    if labindex == endLab
        numToKeep = size(lpA,dim) + szB(dim) - 1;
    else
        numToKeep = size(lpA,dim);
    end

    jj = 1;
    while 1
        needToSend = jj <= numel(sendStages) && sendQty(jj) > 0;
        needToReceive = jj <= numel(receiveStages);
        dimsA = size(lpA);
        index = num2cell(repmat(':',1,ndims(lpA)));

        if needToSend && needToReceive
            if (dim <= ndims(lpA))
                index{dim} = dimsA(dim)-sendQty(jj)+1:dimsA(dim);
            end
            data = subsref(lpA,struct('type','()','subs',{index}));

            dataRcvd = labSendReceive(sendStages(jj),receiveStages(jj),data);
            lpA = cat(dim,dataRcvd,lpA);
            startIdx = startIdx + size(dataRcvd,dim);
        else
            if needToSend
                if (dim <= ndims(lpA))
                    index{dim} = dimsA(dim)-sendQty(jj)+1:dimsA(dim);
                end
                data = subsref(lpA,struct('type','()','subs',{index}));
                labSend(data,sendStages(jj));
            else
                if needToReceive
                    dataRcvd = labReceive(receiveStages(jj));
                    lpA = cat(dim,dataRcvd,lpA);
                    startIdx = startIdx + size(dataRcvd,dim);
                else
                    break
                end
            end
        end
        jj = jj + 1;
    end

    % We must avoid zero-padding because it can turn Infs into NaNs (g1310295).
    % Instead do the 'full' convolution locally and then extract the region
    % we want to keep.
    if isstruct(B)
        c = convFcnHandle(B.hrow, B.hcol, lpA, 'full');
    else
        c = convFcnHandle(lpA, B, 'full');
    end

    index = num2cell(repmat(':',1,ndims(c)));
    index{dim} = startIdx+(1:numToKeep);

    c = subsref(c,struct('type','()','subs',{index}));
else
    % Handle the case where the local part is empty
    sz0 = gSize;
    sz0(dim) = 0;
    c = zeros(sz0,outClass);
end

part(endLab) = part(endLab) + max(maxSend,0);

if isConv
    %Handle the particular case for 1D convolution
    [c,dim,gSize] = iCorrectShape1dConv(c,dim,gSize,isResultRow,A);
end

C = codistributed.build(c,codistributor1d(dim,part,gSize));
m = szB; %Size information to extract out the correct shape
end


function [c,dim,gSize] = iCorrectShape1dConv(c,dim,gSize,isResultRow,A)
% Helper function for 1D convolution: return the correct shaped c (c is a
% local array), the correct dimension and globlal size.

if isResultRow
    gSize = sort(gSize,'ascend');
    if iscolumn(A)
        c = c.';
        dim = 3 - dim;
    end
else
    gSize = sort(gSize,'descend');
    if isrow(A)
        c = c.';
        dim = 3 - dim;
    end
end

end
