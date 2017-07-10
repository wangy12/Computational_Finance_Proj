function  [x_optimal, cash_optimal, weight] = strat_max_Sharpe(x_init, cash_init, mu, Q, cur_prices, portfValue_lastPeriodEnd)

    % strategy 4 - max Sharpe ratio
    
    % how to calculate risk free rate?
    rf = 0.0005; % a parameter defined by student
    
    
    num_portf = length(x_init); % number of portfolio - 20

    
    % weight
    %     weight = inv(Q)*(mu - riskFreeR * ones(num_portf, 1))/( ones(num_portf, 1)' * inv(Q)*(mu - riskFreeR * ones(num_portf, 1)) );
    
    % weight
    % cplexqp solves minimization problems
    % 21 decision variables: 20 weight and K -- vector size = 21*1
    % adjust the matrix and vector: adding equations related to K
    % implement as lecture 4 page 33
    f = zeros(num_portf+1, 1);
    H = zeros(num_portf+1,num_portf+1);
    H(1:num_portf, 1:num_portf) = Q;
    Aeq1 = [mu - rf*ones(num_portf, 1);0]';
    beq1 = 1;
    Aeq2 = [ones(1, num_portf) -1];
    beq2 = 0;
    Aeq = [Aeq1; Aeq2]; % there are 2 equations
    beq = [beq1; beq2];

    lb = zeros(num_portf+1, 1);
    ub = inf*ones(num_portf+1,1);
    options.display = 'off'; % disable Cplex output to the screen
    
%     options = cplexoptimset;
    
    w = cplexqp(H,f,[ ],[ ],Aeq,beq,lb,ub,[ ],options);

    weight = w(1:20)./w(21); % weight = w(1:20)/sum(w(1:20));
   
    % portfolio asset amount
    x_new = portfValue_lastPeriodEnd .* weight ./ cur_prices';
   
    % round
    [rebalPortfVal, transFee, cash_optimal, x_optimal] = roundStrategy(x_new, x_init, cur_prices, portfValue_lastPeriodEnd, cash_init);
    % the first two variables are not used
    

end