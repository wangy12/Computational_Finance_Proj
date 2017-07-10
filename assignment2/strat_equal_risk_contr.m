function [ x_optimal, cash_optimal ] = strat_equal_risk_contr( x_init, cash_init, mu, Qcal, cur_prices, period, strategy )
% Random data for 10 stocks


global Q n;
n = 20;
Q = Qcal;

% which -all ipopt
addpath('F:\project\Fin706\assignment2\IPOPT\examples');

% Equality constraints
A_eq = ones(1,n); b_eq = 1;

% Inequality constraints
A_ineq = []; b_ineql = []; b_inequ = [];

% Define initial portfolio ("1/n portfolio")
w0 = repmat(1.0/n, n, 1);

options.lb = zeros(1,n); % lower bounds on variables
options.lu = ones (1,n); % upper bounds on variables
options.cl = [b_eq' b_ineql']; % lower bounds on constraints
options.cu = [b_eq' b_inequ']; % upper bounds on constraints

% Set the IPOPT options
options.ipopt.jac_c_constant = 'yes';
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy = 'adaptive';
options.ipopt.tol = 1e-10;


% The callback functions
funcs.objective         = @objective;
funcs.constraints       = @constraints;
funcs.gradient          = @gradient;
funcs.jacobian          = @jacobian;
funcs.jacobianstructure = @() sparse(ones(1,20)); % @jacobian; % not sure @jacobian or ones(20,1)


[w_erc, info] = ipopt(w0', funcs, options);

w_erc = transpose(w_erc);
x_new = (cur_prices*x_init + cash_init)* w_erc./cur_prices';
[x_optimal, cash_optimal] = roundStrategy( x_init, x_new, cur_prices, cash_init, period, strategy);

funcs.gradient          = @(w0)computeGradERC(w0,Q);
% gradValue = computeGradERC (x,Q)
[w_erc2, info2] = ipopt(w0', funcs, options);
% a comparison
w_erc - w_erc2'
end
% , Q, n
function f = objective(w_erc)
    global Q n;
    f = 0;
    Qw = Q*w_erc';
    for i= 1:n
        for j = 1:n
            f = f + (w_erc(i)*Qw(i) - w_erc(j)*Qw(j))^2;
        end
    end

end

% analytical
function g = gradient(w_erc)
    % h=10^-8;
    global Q n;

    g = zeros(n, 1);

    for i= 1:n
        
        for j = 1:n
            g(i) = g(i) + 2 * ( w_erc(i) * (Q(i,:) * w_erc') - w_erc(j) * (Q(j,:) * w_erc') ) * ...
                (Q(i,:) * w_erc' + w_erc(i) * Q(i,i) - w_erc(j) * Q(j,i) );
        end
        
    end

end

% to verify the analytical result, I use the following method
% % ============ forward difference method ============ % %
% function g = gradient(w_erc)
%     h=10^-8;
%     global Q n;
% 
%     gh = zeros(n, 1);
% 
%     for i= 1:n
%         w_erch = w_erc;
%         w_erch(i) = w_erc(i) + h;
%         for j = 1:n
%             gh(i) = gh(i) + ( (w_erc(i) + h)*Q(i,:)*w_erch' - w_erc(j)*Q(j,:)*w_erch' )^2 - ...
%                 ( w_erc(i)*Q(i,:)*w_erc' - w_erc(j)*Q(j,:)*w_erc' )^2;
%         end
%         
%     end
%     g = gh./h;
% end



% % % % old one -- maybe wrong
% % % function g = gradient(w_erc)
% % %     % h=10^-8;
% % %     global Q n;
% % %     Qw = Q*w_erc';
% % %     g = zeros(n, 1);
% % % 
% % %     for i= 1:n
% % %         xx = 0;
% % %         for j = 1:n
% % %             xx = xx + w_erc(j)*Qw(j);
% % %         end
% % %         g(i) = 4*Qw(i)*(n*w_erc(i)*Qw(i) - xx);
% % %     end
% % % 
% % % end

function c = constraints(w_erc)
    c = sum(w_erc);
%     c = [sum(w_erc); w_erc];
end

function J = jacobian(w_erc)
    J = sparse( ones(1,20) );
%     J = sparse( [ones(1,20);eye(20)] );
end

function gradValue = computeGradERC(x,Q)
  
  numAssets = length(x); 
  
  if(size(x,1)==1)
     x = x';
  end
  
  %%Evaluate the gradient
  gradValue = zeros(numAssets,1);
  Qx = Q*x;
  
  %%Evaluate function
  y = x .* (Qx);
  
  for k = 1:numAssets %k iterates through positions in the gradient
    for i = 1:numAssets
        for j = 1:numAssets
            xij = y(i) - y(j);
            if (i == k)
                if (j == k)
                    %If i == j, do nothing
                else
                    gradValue(k) = gradValue(k) + ...
                        2*xij*(Qx(k) + x(k)*Q(k,k) - x(j)*Q(j,k));
                end
            else %(i != k)
                if (j == k)
                   gradValue(k) = gradValue(k) + ...
                       2*xij*(x(i)*Q(i,k) + x(k)*Q(k,k) - Qx(k));
                else
                    gradValue(k) = gradValue(k) + ...
                        2*xij*(x(i)*Q(i,k) - x(j)*Q(j,k));
                end
            end
        end
    end
  end
 
end
