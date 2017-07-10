function  [new_prices] = tax_algorithm(cur_prices, purchases)

tic
    fun = @(x)sum( mod( round(100 * 1.13 * purchases * (cur_prices + 0.01*x') ), 5)~=0 );
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = -2*ones(size(cur_prices));
    ub = 2*ones(size(cur_prices));
    nvars = length(cur_prices);
    x = ga(fun,nvars,A,b,Aeq,beq,lb,ub,[],[1:12]);
    new_prices = cur_prices + 0.01*x';
toc

end

