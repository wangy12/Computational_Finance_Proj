function  [x_optimal, cash_optimal, weight] = strat_equally_weighted(x_init, cash_init, mu, Q, cur_prices, portfValue_lastPeriodEnd)

    % strategy 2 - equally weighted
    
    num_portf = length(x_init); % number of portfolio - 20
    % w_i = 1/n = (v_i*x_i)/V
    % --> x_i = V*v_i/n

    weight = 1/num_portf * ones(num_portf, 1);
    
    % cash funds are used to stock purchases
    
    % new (updated) asset shares
    % here the 'V' uses portfolio value of the end day of last period
    x_new = ( portfValue_lastPeriodEnd/num_portf)./cur_prices';
    
    % round - this is a round method
    % floor, ceil and round are used, and the feasible solution with max
    % portfolio value is selected
    [rebalPortfVal, transFee, cash_optimal, x_optimal] = roundStrategy(x_new, x_init, cur_prices, portfValue_lastPeriodEnd, cash_init);
    % the first two variables are not used
    
end