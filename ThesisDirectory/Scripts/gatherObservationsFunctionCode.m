function observations = gatherObservations(entitiesInBuffer1, entitiesInBuffer2, entitiesInBuffer3, ...
                                           entitiesInBuffer4, ReadyProducts, ReadyClients, ...
                                           machineStatus1, machineStatus2, machineStatus3, ...
                                           machineStatus4, machineStatus5)
    % Define maximum buffer capacity
    maxBufferCapacity = 50; 

    % Normalize buffer levels
    bufferLevels = [entitiesInBuffer1; entitiesInBuffer2; entitiesInBuffer3; entitiesInBuffer4] / maxBufferCapacity;

    % Normalize ready products and clients
    readyStates = [ReadyProducts; ReadyClients] / maxBufferCapacity;

    % Normalize machine states to [0, 1]
    machineStates = [machineStatus1; machineStatus2; machineStatus3; machineStatus4; machineStatus5];

    % Combine normalized observations into a single vector
    observations = [bufferLevels; readyStates; machineStates];
end
