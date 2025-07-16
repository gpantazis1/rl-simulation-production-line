% Parameters
lambda = 1 / 4.5;  % Demand rate
mu1 = 1 / 2;       % Production rate Machine 1
mu2 = 1 / 2;       % Production rate Machine 2
f1 = 1 / 50;       % Failure rate Machine 1
f2 = 1 / 50;       % Failure rate Machine 2
r1 = 1 / 5;        % Repair rate Machine 1
r2 = 1 / 5;        % Repair rate Machine 2
h1 = 0.5;          % Intermediate buffer cost
h2 = 1.0;          % Finished products cost
b = 1.3;           % Backorder cost
Mx = 50;           % Max intermediate buffer
My = 50;           % Max finished products buffer, y from -My to My
e = 1e-6;          % Convergence tolerance
dt = 0.1;          % Time step

% Total event rate
v = lambda + mu1 + mu2 + f1 + f2 + r1 + r2;

% State space dimensions
V_k = zeros(Mx + 1, 2, 2 * My + 1, 2);
y_shift = My + 1;

% Value iteration
Diff = inf;
iter = 0;
printInterval = 10;

fprintf('Iteration\tDiff\t\tCost per step\n');
fprintf('----------------------------------------\n');

while Diff > e
    iter = iter + 1;
    V_new = zeros(size(V_k));
    minDV = inf;
    maxDV = -inf;
    
    for ix = 1:Mx + 1
        for ii1 = 1:2
            for iy = 1:2 * My + 1
                for ii2 = 1:2
                    x = ix - 1;
                    i1 = ii1 - 1;
                    y = iy - y_shift;
                    i2 = ii2 - 1;
                    
                    cost = h1 * x + h2 * max(y, 0) + b * max(-y, 0);
                    trans_sum = 0;
                    
                    % Machine 1 production
                    if i1 == 1
                        if x < Mx
                            trans_sum = trans_sum + mu1 * min(V_k(ix + 1, ii1, iy, ii2), V_k(ix, ii1, iy, ii2));
                        else
                            trans_sum = trans_sum + mu1 * V_k(ix, ii1, iy, ii2);
                        end
                    end
                    
                    % Machine 2 production
                    if x > 0 && i2 == 1
                        if y < My
                            trans_sum = trans_sum + mu2 * min(V_k(ix - 1, ii1, iy + 1, ii2), V_k(ix, ii1, iy, ii2));
                        else
                            trans_sum = trans_sum + mu2 * V_k(ix, ii1, iy, ii2);
                        end
                    end
                    
                    % Demand
                    if y > -My
                        trans_sum = trans_sum + lambda * V_k(ix, ii1, iy - 1, ii2);
                    else
                        trans_sum = trans_sum + lambda * V_k(ix, ii1, iy, ii2);
                    end
                    
                    % Failures
                    if i1 == 1
                        trans_sum = trans_sum + f1 * V_k(ix, 1, iy, ii2);
                    end
                    if i2 == 1
                        trans_sum = trans_sum + f2 * V_k(ix, ii1, iy, 1);
                    end
                    
                    % Repairs
                    if i1 == 0
                        trans_sum = trans_sum + r1 * V_k(ix, 2, iy, ii2);
                    end
                    if i2 == 0
                        trans_sum = trans_sum + r2 * V_k(ix, ii1, iy, 2);
                    end
                    
                    % Self-loop rate
                    self_rate = 0;
                    if i1 == 0, self_rate = self_rate + mu1; end
                    if ~(x > 0 && i2 == 1), self_rate = self_rate + mu2; end
                    if i1 == 0, self_rate = self_rate + f1; end
                    if i2 == 0, self_rate = self_rate + f2; end
                    if i1 == 1, self_rate = self_rate + r1; end
                    if i2 == 1, self_rate = self_rate + r2; end
                    trans_sum = trans_sum + self_rate * V_k(ix, ii1, iy, ii2);
                    
                    V_new(ix, ii1, iy, ii2) = (trans_sum + cost) / v;
                    
                    dv = V_new(ix, ii1, iy, ii2) - V_k(ix, ii1, iy, ii2);
                    minDV = min(minDV, dv);
                    maxDV = max(maxDV, dv);
                end
            end
        end
    end
    
    % Normalize value function
    ref_value = V_new(1,1,y_shift,1);
    V_new = V_new - ref_value;
    
    % Calculate current cost per step
    current_cost = v * (ref_value - V_k(1,1,y_shift,1)) * dt;
    
    Diff = maxDV - minDV;
    V_k = V_new;
    
    if mod(iter, printInterval) == 0
        fprintf('%d\t\t%.6f\t%.6f\n', iter, Diff, current_cost);
    end
end

% Final optimal cost per step
J_DP = v * (ref_value - V_k(1,1,y_shift,1)) * dt;

fprintf('\nFinal Results:\n');
fprintf('----------------------------------------\n');
fprintf('Number of iterations: %d\n', iter);
fprintf('Final difference: %.6f\n', Diff);
fprintf('Optimal average cost per time step: %.6f\n', J_DP);

% Extract optimal policies
Dec1 = zeros(Mx + 1, 2 * My + 1, 2);
Dec2 = zeros(Mx + 1, 2 * My + 1, 2);

for ix = 1:Mx + 1
    for iy = 1:2 * My + 1
        for ii2 = 1:2
            if ix < Mx + 1
                Dec1(ix, iy, ii2) = (V_k(ix + 1, 2, iy, ii2) <= V_k(ix, 2, iy, ii2));
            end
        end
        for ii1 = 1:2
            if ix > 1 && iy < 2 * My + 1
                Dec2(ix, iy, ii1) = (V_k(ix - 1, ii1, iy + 1, 2) <= V_k(ix, ii1, iy, 2));
            end
        end
    end
end
