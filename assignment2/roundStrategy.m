function [x_optimal, cash_optimal] = roundStrategy( x_init, x_new, cur_prices, cash_init, period, strategy)

% transaction fees
fee_rate = 0.005;

x_f = floor(x_new);
portfVal_old = cur_prices * x_init + cash_init;  %the portfolio value based on the weight of the last period
transFee = cur_prices * abs(x_f-x_init) * fee_rate;
portfVal_new = cur_prices * x_f - transFee; 
cash = portfVal_old - portfVal_new ;

% Verify that strategy is feasible (you have enough budget to re-balance portfolio)
% Check that cash account is >= 0
% Check that we can buy new portfolio subject to transaction costs
if cash < 0
    fprintf('Strategy %d Period %d is infeasible. "Hold" the assets as previous period.\n', strategy , period ); 
    % hold as previous period
    x_optimal = curr_positions;
    cash_optimal = curr_cash;
else
    %rounding strategy
    %sort the stock prices in the ascending order
    x_n=zeros(20,4);
    x_n(:,1)=cur_prices';
    x_n(:,2)=x_f;
    x_n(:,3)=ceil(x_new);
    x_n(:,4)=linspace(1,20,20);
    sorted = sortrows(x_n,1);  
    % caculate the cash balance after ceiling the number of stocks one by one
    % from the lowest price to the highest price
    for i = 1 : 20;
        if cash >= 0; %make sure the cash balance will be non-nagetive
            cash = cash- sorted(i,1)'*(sorted(i,3)-sorted(i,2))*fee_rate;
            sorted(i,2) = sorted(i,3);
        end        
    end 
    transFee = sorted(:,1)'*sorted(:,2)*fee_rate;
    x_n = sortrows(sorted,4);
    x_optimal = x_n(:,2);  
    cash_optimal = cash;
end

end

