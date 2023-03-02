function [C,szInfo] = convDistDist(A,B,convFcnHandle,outClass,isResultRow)
% Perform convolution of two distributed arrays A and B with appropriate
% shape. isResultRow is an optional parameter used by conv (1D convolution)
% to return a result with the right shape

% Copyright 2016 The MathWorks, Inc.

codistrB = getCodistributor(B);
partB = codistrB.Partition;
cumPartB = cumsum(partB);

szB = codistrB.Cached.GlobalSize;
dim = codistrB.Dimension;

isConv = isequal(convFcnHandle, @conv);
if isConv
    assert(nargin==5);
    [dim,szB] = iReshapeToCat(szB,isResultRow);
end

otherdim = [1:dim-1 dim+1:max([ndims(A);ndims(B)])];
% These sizes will be used to build new matrices
szInfo = szB;
szZeroM = szB;
szZeroL = szB;
firstIteration = true;


% For every lab that contains a part of B, the algorithm goes through it by
% turn and then replicates the data across all workers. Following this it
% calls iDistReplConv, stores the answer and adds it to an accumulator C.
for ii = 1:numlabs
    if partB(ii) == 0
        % Local part empty so skip
        continue;
    end

    if ii == labindex
        dataShared = labBroadcast(ii,getLocalPart(B));
    else
        dataShared = labBroadcast(ii);
    end

    if isConv
        temp = convDistRepl(A,dataShared,convFcnHandle,outClass,isResultRow);
    else
        temp = convDistRepl(A,dataShared,convFcnHandle,outClass);
    end

    if firstIteration % Set up accumulator C
        C = temp;
        firstIteration = false;
    else
        % Make temp and C of the same length by padding some zeros to the
        % left of temp and right of current accumulator C before adding to
        % the final accumulator C
        szZeroM(dim) = cumPartB(ii-1);
        szT = [size(temp) ones(1,dim-ndims(temp))];
        m = szT(dim) + szZeroM(dim);

        szC = [size(C) ones(1,dim-ndims(C))];
        szZeroL(dim) = m - szC(dim);
        szZeroM(otherdim) = szC(otherdim);
        szZeroL(otherdim) = szC(otherdim);

        C = cat(dim,zeros(szZeroM,'like',temp),temp) + cat(dim,C,zeros(szZeroL,'like',C));
    end
end
end

function [dim,szB] = iReshapeToCat(szB,isResultRow)
% Reshape szB to correctly pad the result

if isResultRow
    szB = sort(szB,'ascend');
    dim = 2;
else
    szB = sort(szB,'descend');
    dim = 1;
end
end
