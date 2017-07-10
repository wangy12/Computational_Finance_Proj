function  [new_prices] = tax_algorithm2(cur_prices, purchases)

tic
    fun = @(x)sum( mod( round(100 * 1.13 * purchases * (cur_prices + x') ), 5)~=0 );
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = -0.02*ones(size(cur_prices)); % -0.02<=x<=0.02 continuous
    ub = 0.02*ones(size(cur_prices));
    nvars = length(cur_prices);
    x = ga(fun,nvars,A,b,Aeq,beq,lb,ub);
    new_prices = round((cur_prices + x')*100)/100;
toc

end