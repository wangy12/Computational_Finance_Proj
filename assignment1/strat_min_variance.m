function  [x_optimal, cash_optimal, weight] = strat_min_variance(x_init, cash_init, mu, Q, cur_prices, portfValue_lastPeriodEnd)

    % strategy 3 - min variance
    
    num_portf = length(x_init); % number of portfolio - 20

    %     c = ones(num_portf,1)'*inv(Q)*ones(num_portf,1); % 
    
    % Ref: Portfolio Optimization: Beyond Markowitz, Master's Thesis by
    % Marnix Engels, January 13, 2004
    %     X = inv(Q)*ones(num_portf,1)*(curPortfVal + cash_init)/c;
    % calculate asset weights
    % lagrange multipler methods
    %     lambda = 1/( -0.5*sum( inv(Q)*ones(num_portf,1) ) );
    %     weight = -inv(Q)*ones(num_portf,1)*lambda/2;
    
    % http://www.ibm.com/support/knowledgecenter/SSSA5P_12.2.0/ilog.odms.cplex.help/Content/Optimization/Documentation/CPLEX/_pubskel/CPLEX1200.html

    % cplexqp solves minimization problems
    f = zeros(num_portf, 1);
    H = Q;
    Aeq = ones(1, num_portf);
    beq = 1;
    lb = zeros(num_portf, 1);
    ub = inf*ones(num_portf,1);
    

    options.display = 'off';
    
    % this 'cplexqp' works the same way as MATLAB 'quadprog'
    weight = cplexqp(H,f,[ ],[ ],Aeq,beq,lb,ub,[ ],options);
   

    % portfolio asset amount
    x_new = portfValue_lastPeriodEnd .* weight ./ cur_prices';
   
    % round
    [rebalPortfVal, transFee, cash_optimal, x_optimal] = roundStrategy(x_new, x_init, cur_prices, portfValue_lastPeriodEnd, cash_init);
    % the first two variables are not used
    
    
end