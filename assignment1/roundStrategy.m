function [PortfVal, TransFee, Cash, x_optimal] = roundStrategy(x_new, x_init, cur_prices, portfValue_lastPeriodEnd, cash_init)

x_r = zeros(length(x_new), 3);
protfVal = zeros(3,1);
transFee = zeros(3,1);
cash = zeros(3,1);

% transaction fees
fee_rate = 0.005;
    
% round strategy 1 - floor
x_r(:,1) = floor(x_new);
transFee(1) = cur_prices * abs(x_r(:,1) - x_init) * fee_rate;
protfVal(1) = cur_prices * x_r(:,1) - transFee(1); % Pi
% cash(1) = portfValue_lastPeriodEnd - cur_prices * x_r(:,1) - transFee(1);
cash(1) = portfValue_lastPeriodEnd - cur_prices * x_r(:,1) + cash_init; % - transFee(1);
% there may be mistake here: transaction cost is not included in the cash

% round strategy 2 - ceil
x_r(:,2) = ceil(x_new);
transFee(2) = cur_prices * abs(x_r(:,2) - x_init) * fee_rate;
protfVal(2) = cur_prices * x_r(:,2) - transFee(2); % Pi
% cash(2) = portfValue_lastPeriodEnd - cur_prices * x_r(:,2) - transFee(2);
cash(2) = portfValue_lastPeriodEnd - cur_prices * x_r(:,2) + cash_init; % - transFee(2);

% round strategy 3 - round
x_r(:,3) = round(x_new);
transFee(3) = cur_prices * abs(x_r(:,3) - x_init) * fee_rate;
protfVal(3) = cur_prices * x_r(:,3) - transFee(3); % Pi
% cash(3) = portfValue_lastPeriodEnd - cur_prices * x_r(:,3) - transFee(3);
cash(3) = portfValue_lastPeriodEnd - cur_prices * x_r(:,3) + cash_init; % - transFee(2);

% find feasible solution methods
idxFeasible = find(cash > 0);


if isempty(idxFeasible)
    % infeasible
    [PortfVal, idx] = max(protfVal);
    x_optimal = x_r(:,idx);
    TransFee = transFee(idx);
    Cash = cash(idx);
else
    % find the max portfolio value from all feasible round methods
    [PortfVal, idx] = max(protfVal(idxFeasible));
    x_optimal = x_r(:,idxFeasible(idx));
    TransFee = transFee(idxFeasible(idx));
    Cash = cash(idxFeasible(idx));
end

