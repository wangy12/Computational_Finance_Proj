function  [x_optimal, cash_optimal, weight] = strat_min_variance(x_init, cash_init, mu, Q, cur_prices, period, strategy)
    % strategy 3 - min variance
    warning('off', 'all');
    addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64');
    
    n = length(x_init); % number of portfolio - 20
    A = ones(1, n);
    b = 1;
    lb = zeros(n, 1);
    ub = inf*ones(n,1);
    
    cplex = Cplex('min_Variance');
    cplex.addCols(zeros(n,1), [], lb, ub);
    cplex.addRows(b, A, b);
    cplex.Model.Q = 2*Q;
    cplex.Param.qpmethod.Cur = 6; % concurrent algorithm
    cplex.Param.barrier.crossover.Cur = 1; % enable crossover
    cplex.DisplayFunc = []; % disable output to screen
    cplex.solve();
    options.display = 'off';
    
    weight = cplex.Solution.x;

    % portfolio asset amount
    x_new = (cur_prices*x_init + cash_init)* weight ./ cur_prices';
   
    % rounding
    [x_optimal, cash_optimal] = roundStrategy( x_init, x_new, cur_prices, cash_init, period, strategy);
    
end