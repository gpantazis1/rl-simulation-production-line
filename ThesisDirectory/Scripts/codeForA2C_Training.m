%% Step 1: Define the Environment
mdl = 'productionLine_5machines';
agentBlk = [mdl '/RL Agent'];

% Define observation specifications
obsInfo = rlNumericSpec([11, 1], ...
    'LowerLimit', [0; 0; 0; 0; 0; 0; -1; -1; -1; -1; -1], ...
    'UpperLimit', [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1]);    
obsInfo.Name = 'Production Line States';

%% Define Action Specifications Using dec2bin
actions = dec2bin(0:31, 5) - '0'; 
actInfo = rlFiniteSetSpec(mat2cell(actions, ones(1, 32), 5));
actInfo.Name = 'MachineActions';

% Create the environment
env = rlSimulinkEnv(mdl, agentBlk, obsInfo, actInfo);

%% Step 2: Define Actor and Critic Networks

% Observation and action dimensions
obsDim = prod(obsInfo.Dimension);
actDim = size(actions, 1);

% Actor Network with initialized weights
actorNet = [
    featureInputLayer(obsDim, 'Normalization', 'none', 'Name', 'obsInput')
    fullyConnectedLayer(128, 'Name', 'fc1', ... 
        'WeightLearnRateFactor', 1, ...
        'WeightsInitializer', 'glorot')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2', ...
        'WeightLearnRateFactor', 1, ...
        'WeightsInitializer', 'glorot')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actDim, 'Name', 'fcOutput', ...
        'WeightsInitializer', 'zeros')
    softmaxLayer('Name', 'actionProb')];

% Critic Network with initialized weights
criticNet = [
    featureInputLayer(obsDim, 'Normalization', 'none', 'Name', 'obsInput')
    fullyConnectedLayer(128, 'Name', 'fc1', ...
        'WeightLearnRateFactor', 1, ...
        'WeightsInitializer', 'glorot')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2', ...
        'WeightLearnRateFactor', 1, ...
        'WeightsInitializer', 'glorot')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(1, 'Name', 'value', ...
        'WeightsInitializer', 'zeros')];

% Create actor and critic representations
actor = rlDiscreteCategoricalActor(actorNet, obsInfo, actInfo);
critic = rlValueFunction(criticNet, obsInfo);

%% Step 3: AC Agent Options

agentOpts = rlACAgentOptions(...
    'Sample Time', 1, ...
    'EntropyLossWeight', 0.1, ...    % Increased from PPO's 0.02
    'DiscountFactor', 0.995, ...
    'NumSteps', 32, ...               % Number of steps per update
    'ActorOptimizerOptions', rlOptimizerOptions('LearnRate', 2e-4, 'GradientThreshold', 1), ... 
    'CriticOptimizerOptions', rlOptimizerOptions('LearnRate', 1e-4, 'GradientThreshold', 1));

% Create AC Agent
agent = rlACAgent(actor, critic, agentOpts);

%% Step 4: Training Options
trainOpts = rlTrainingOptions(...
    'MaxEpisodes', 20000, ...
    'MaxStepsPerEpisode', 2000, ...
    'ScoreAveragingWindowLength', 100, ... 
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', -100);         

% Train the agent
trainingStats = train(agent, env, trainOpts);

% Save the trained agent
save('trainedAgent_5machines_A2C.mat', 'agent');
save('trainingStats_5machines_A2C.mat', 'trainingStats');

disp('Training completed and agent saved.');
