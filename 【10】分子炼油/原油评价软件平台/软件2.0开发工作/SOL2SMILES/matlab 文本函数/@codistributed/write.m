function write(location, d)
%WRITE  Write codistributed data to an output location.
%   WRITE(LOCATION,D) writes the values in the codistributed array D to
%   files in the folder LOCATION. The data is stored in an efficient binary
%   format suitable for reading back using DATASTORE(LOCATION).
%   
%   Example:
%   spmd
%      % Create codistributed array and write it to an output folder
%      d = codistributed.rand(5000,1);
%      location = 'hdfs://myHadoopCluster/some/output/folder';
%      write(location, d);
%   
%      % Recreate the codistributed array from the written files
%      ds = datastore(location);
%      d1 = codistributed(ds);
%   
%      % Create a tall array from the written files
%      ds = datastore(location);
%      t1 = tall(ds);
%   end
%   
%   See also: codistributed, DATASTORE, TALL.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);

% Check or create the write location
% If the location cannot be deduced, the location return value will be an
% exception.
[location, isHdfs] = iCheckLocation(location);
if isa(location, 'MException')
    throw(location);
end

% Distributed array must be 1D in rows
codistr = getCodistributor(d);
if ~isa(codistr, 'codistributor1d') || codistr.Dimension ~= 1
    d = redistribute(d, codistributor1d(1));
end

% Now try to write the data
err = [];
try
    writeFunction = matlab.bigdata.internal.io.WriteFunction.createWriteToBinaryFunction(location, isHdfs);
    info = struct( ...
        'PartitionId', labindex, ...
        'NumPartitions', numlabs, ...
        'IsLastChunk', true );
    % We pass all data in a single chunk
    feval(writeFunction, info, getLocalPart(d));
    
catch err
end
% Check for errors over all workers, and if any errored, throw the first.
err = gcat(err);
if ~isempty(err)
    throw(err(1));
end
end


function [location, isHdfs] = iCheckLocation(location)
% Helper to check the location on one worker and ensure all workers have
% the result.

% Only one worker should create the output folder and check for HDFS.
if labindex == 1
    % Check that first input is an existing folder on the worker. This will
    % throw if there is an access problem, in which case we send the
    % exception to the other workers instead.
    try
        [location, isHdfs] = matlab.bigdata.internal.util.validateLocation(location);
        data_out = labBroadcast( 1, {location, isHdfs} );
    catch err
        data_out = labBroadcast( 1, {err, []} );
    end
else
    data_out = labBroadcast( 1 );
end
location = data_out{1};
isHdfs = data_out{2};

end
