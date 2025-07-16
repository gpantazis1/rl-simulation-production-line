
T1_values = 1:1:10;  % Threshold range for Machine 1 (idle to working)
T2_values = 1:1:50;  % Threshold range for Machine 1 (working to idle)


simulationTime = 10000;  % Simulation time in the model


bestCost = inf;
bestT1 = NaN;
bestT2 = NaN;

% Simulink model name
modelName = 'productionLine2machines_withoutAgent';  

% Load Simulink model
load_system(modelName);

% Loop over all valid combinations of T1 and T2
for T1 = T1_values
    for T2 = T2_values
        if T1 == T2
            continue;  
        end

       
        assignin('base', 'T1', T1);
        assignin('base', 'T2', T2);

        % Run the simulation
        simOut = sim(modelName, 'StopTime', num2str(simulationTime), ...
                     'SaveOutput', 'on', 'SignalLogging', 'on');

       
        totalCostTS = simOut.get('TotalCost');
        costValues = totalCostTS.Data;    % Cost values over time

      
        finalCost = sum(costValues);  

        
        fprintf('Tested T1 = %d, T2 = %d --> Total Cost = %.2f\n', T1, T2, finalCost);

       
        if finalCost < bestCost
            bestCost = finalCost;
            bestT1 = T1;
            bestT2 = T2;
        end
    end
end

% Display optimal results
fprintf('\nOptimal Thresholds Found:\n');
fprintf('T1 = %d, T2 = %d with Minimum Total Cost = %.2f\n', bestT1, bestT2, bestCost);

