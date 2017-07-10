function [ x_optimal, cash_optimal] =  strat_robust_optim( x_init, cash_init, mu, Q, cur_prices, period, strategy )
% Random data for 10 stocks
n = 20;

addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64');

% Initial portfolio ("equally weighted" or "1/n")
w0 = ones(n,1) ./ n;

ret_init = dot(mu, w0); % 1/n portfolio return
var_init = w0' * Q * w0; % 1/n portfolio variance

% Bounds on variables
lb_rMV = zeros(n,1); ub_rMV = inf*ones(n,1);

% Target portfolio return estimation error
var_matr = diag(diag(Q));
rob_init = w0' * var_matr * w0; % r.est.err. of 1/n portf
rob_bnd = rob_init; % target return estimation error---may be modified later---how to determine the target estimation error??

% Target portfolio return = return of MVP
Portf_Retn = ([0.02475, 0.0282, 0.0297, 0.03405, 0.0364, 0.0397, 0.0444, 0.04675, 0.0488, 0.05085, 0.0499, 0.0502] + 1.12).^(1/252)-1;

%Formulate and solve robust mean-variance problem
f_rMV = zeros(n,1); % objective function

% Constraints
A_rMV = sparse([ mu'; ones(1,n)]);
lhs_rMV = [Portf_Retn(1, period); 1]; 
rhs_rMV = [inf; 1];

% Create CPLEX model
cplex_rMV = Cplex('Robust_MV');
cplex_rMV.addCols(f_rMV, [], lb_rMV, ub_rMV);
cplex_rMV.addRows(lhs_rMV, A_rMV, rhs_rMV);

% Add quadratic objective
cplex_rMV.Model.Q = 2*Q;
% Add quadratic constraint on return estimation error (robustness constraint)
cplex_rMV.addQCs(zeros(size(f_rMV)), var_matr, 'L', rob_bnd, {'qc_robust'});
% Solve
cplex_rMV.solve();


weight = cplex_rMV.Solution.x;
    
% portfolio asset amount
x_new = (cur_prices*x_init + cash_init)* weight ./ cur_prices';
   
% rounding
[x_optimal, cash_optimal] = roundStrategy( x_init, x_new, cur_prices, cash_init, period, strategy);

end

