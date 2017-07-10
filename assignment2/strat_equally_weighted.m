function  [x_optimal, cash_optimal, weight] = strat_equally_weighted(x_init, cash_init, mu, Q, cur_prices, period, strategy)

    % strategy 2 - equally weighted
    
    stock_type = length(x_init); % number of portfolio - 20

    weight = 1/stock_type * ones(stock_type, 1);

    x_new = ( (cur_prices*x_init + cash_init)/stock_type)./cur_prices';
    
    [x_optimal, cash_optimal] = roundStrategy(x_init, x_new, cur_prices, cash_init, period, strategy);
    
end