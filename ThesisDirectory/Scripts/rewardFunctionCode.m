function reward = calculateReward(EntitiesB1, EntitiesB2, EntitiesB3, EntitiesB4, ReadyProducts, ReadyClients, t)
    % Time tracking
    persistent lastTime
    if isempty(lastTime)
        lastTime = t;
        reward = 0;
        return;
    end

    % Calculate dt
    dt = t - lastTime;
    lastTime = t;

    % Cost weights
    bufferCost = 0.5;    % buffers 1,2,3,4
    productsCost = 1;  % readyProducts Buffer
    clientsCost = 1.3;   % readyClients Buffer

    % Calculate total cost
    totalCost = (EntitiesB1 * bufferCost + EntitiesB2 * bufferCost + EntitiesB3 * bufferCost + EntitiesB4 * bufferCost + ReadyProducts * productsCost + ReadyClients * clientsCost) * dt;



    % Total reward
    reward = -totalCost;
end