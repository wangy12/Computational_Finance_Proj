function  [x_optimal, cash_optimal, weight] = strat_max_Sharpe(x_init, cash_init, mu, Q, cur_prices, period, strategy)

    warning('off', 'all');
    % strategy 4 - max Sharpe ratio
    addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64');
    %the risk free rate is approximated from the 3-month t-bill interest rate http://orfe.princeton.edu/~jqfan/fan/classes/504/Datasets/tb3m.txt 
    rf=([0.02475, 0.0282, 0.0297, 0.03405, 0.0364, 0.0397, 0.0444, 0.04675, 0.0488, 0.05085, 0.0499, 0.0502] + 1).^(1/252)-1;
    n = length(x_init); % number of portfolio - 20
    lb = zeros(n+1,1);
    ub = inf*ones(n+1,1);
    A = [mu' - rf(1, period)*ones(1, n),0];
    
    % Compute maximize sharpe portfolio
    cplex = Cplex('QPproblem');
    cplex.Model.sense = 'minimize';
    cplex.addCols(zeros(n+1,1), [], [lb], [ub]);
    cplex.addRows(1, A, 1);
    cplex.addRows(0, [ones(1,n),-1], 0);
    cplex.addRows(0, [zeros(1,n),1],inf);
    cplex.Model.Q = [2*Q zeros(n,1); zeros(1,n+1)];
    cplex.Param.qpmethod.Cur = 6; % concurrent algorithm
    cplex.Param.barrier.crossover.Cur = 1; % enable crossover
    cplex.DisplayFunc = []; % disable output to screen
    cplex.solve();
   
    y = cplex.Solution.x;
    weight=y(1:20)./y(21);
    
    % portfolio asset amount
    x_new = (cur_prices*x_init + cash_init)* weight ./ cur_prices';
   
    % rounding
    [x_optimal, cash_optimal] = roundStrategy( x_init, x_new, cur_prices, cash_init, period, strategy);
    % the first two variables are not used  

end