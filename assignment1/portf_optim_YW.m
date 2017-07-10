clc; close all;
clear all;
format long

% Input files
input_file_returns = 'Returns.csv';
input_file_prices  = 'Daily_closing_prices.csv';

% Read expected returns
if(exist(input_file_returns,'file'))
    fprintf('\nReading returns datafile - %s\n', input_file_returns)
    fid1 = fopen(input_file_returns);
     % Read instrument tickers
     hheader  = textscan(fid1, '%s', 1, 'delimiter', '\n');
     headers = textscan(char(hheader{:}), '%q', 'delimiter', '\t');
     tickers = headers{1}(2:end);
     % Read time periods
     vheader = textscan(fid1, '%q %*[^\n]');
     periods = vheader{1}(1:end);
    fclose(fid1);
    data_returns = dlmread(input_file_returns, '\t', 1, 1);
else
    error('Returns datafile does not exist')
end

% Read daily prices
if(exist(input_file_prices,'file'))
    fprintf('\nReading daily prices datafile - %s\n', input_file_prices)
    fid2 = fopen(input_file_prices);
     % Read dates
     vheader = textscan(fid2, '%q %*[^\n]');
     dates = vheader{1}(2:end);
    fclose(fid2);
    data_prices = dlmread(input_file_prices, '\t', 1, 1);
else
    error('Daily prices datafile does not exist')
end

% Initial positions in the portfolio
% init_positions = [5000 1000 2000 0 0 0 0 2000 3000 6500 0 0 0 0 0 0 1000 0 0 0]';
% init_positions = [1650 3293 2873 224 2013 1292 2489 1033 937 447 7450 2384 886 1694 2323 1090 4328 1179 3566 1231]';
init_positions = [1885 3427 2653 249 2395 1320 2466 1206 1593 516 8263 2609 1085 2185 2354 1302 6413 1132 3388 1552]';

% Initial value of the portfolio
init_value = data_prices(1,:) * init_positions;
fprintf('\nInitial portfolio value = $ %10.2f\n\n', init_value);

% Initial portfolio weights
w_init = (data_prices(1,:) .* init_positions')' / init_value;

% Number of periods, assets, trading days
N_periods = length(periods);
N = length(tickers);
N_days = length(dates);

% Convert dates into array [year month day]
format_date = 'mm/dd/yyyy';
dates_array = datevec(dates, format_date);
dates_array = dates_array(:,1:3);

% Number of strategies
strategy_functions = {'strat_buy_and_hold' 'strat_equally_weighted' 'strat_min_variance' 'strat_max_Sharpe'};
strategy_names     = {'Buy and Hold' 'Equally Weighted Portfolio' 'Mininum Variance Portfolio' 'Maximum Sharpe Ratio Portfolio'};
% N_strat = 2; % comment this in your code
N_strat = length(strategy_functions); % uncomment this in your code

fh_array = cellfun(@str2func, strategy_functions, 'UniformOutput', false);


for period = 1:N_periods
    % Compute current year and month, first and last day of the period
    if dates_array(1,1)==5
        cur_year  = 5 + floor(period/7);
    else
        cur_year  = 2005 + floor(period/7);
    end
    cur_month = 2*rem(period-1,6) + 1;
    day_ind_start = find(dates_array(:,1)==cur_year & dates_array(:,2)==cur_month, 1, 'first');
    day_ind_end = find(dates_array(:,1)==cur_year & dates_array(:,2)==(cur_month+1), 1, 'last');
    fprintf('\nPeriod %d: start date %s, end date %s\n', period, char(dates(day_ind_start)), char(dates(day_ind_end)));

    % Compute expected return and covariance matrix for period 1
    if(period==1)
        mu = data_returns(period,:)';
        Q  = dlmread(['covariance_' char(periods(period)) '.csv'], '\t', 'A1..T20');
    end

    % Prices for the current day
    cur_prices = data_prices(day_ind_start,:);

    % Execute portfolio selection strategies
    for strategy = 1:N_strat

        % Get current portfolio positions
        if(period==1)
            curr_positions = init_positions;
            curr_cash = 0;
            portf_value{strategy} = zeros(N_days,1);
        else
            curr_positions = x{strategy,period-1};
            curr_cash = cash{strategy,period-1};
        end

        % Compute strategy
        if period == 1
            % hold the initial portfolio in period 1
            [x{strategy,period}, cash{strategy,period}, weight{strategy,period}] = ...
                fh_array{1}(curr_positions, curr_cash, mu, Q, cur_prices, nan); 
            % nan -- not a number, since 'the end day portfolio value of last period' is not available
        else
            % re-balance portfolio from period 2
            [x{strategy,period}, cash{strategy,period}, weight{strategy,period}] = ...
                fh_array{strategy}(curr_positions, curr_cash, mu, Q, cur_prices, portfValue_lastPeriodEnd);
%             [x{strategy,period}, cash{strategy,period}, weight{strategy,period}] = ...
%                 strat_equally_weighted(curr_positions, curr_cash, mu, Q, cur_prices, portfValue_lastPeriodEnd);
        end
        
        
        % Verify that strategy is feasible (you have enough budget to re-balance portfolio)
        % Check that cash account is >= 0
        % Check that we can buy new portfolio subject to transaction costs
        if cash{strategy,period} < 0
            % cash is a negative number
            %             pause
            fprintf('Strategy %d Period %d is infeasible. "Hold" the assets as previous period.\n', strategy , period );
            % hold as previous period
            x{strategy,period} = curr_positions;
            cash{strategy,period} = curr_cash;
            if period == 1
                weight{strategy,period} = w_init;
            else
                weight{strategy,period} = weight{strategy,period-1};
            end
        end

        % Compute portfolio value
        portf_value{strategy}(day_ind_start:day_ind_end) = ...
            data_prices(day_ind_start:day_ind_end,:) * x{strategy,period} + cash{strategy,period};

        fprintf('   Strategy "%s", value begin = $ %10.2f, value end = $ %10.2f\n', ...
        char(strategy_names{strategy}), portf_value{strategy}(day_ind_start), portf_value{strategy}(day_ind_end));

        portfValue_lastPeriodEnd = portf_value{strategy}(day_ind_end);
    end

    % Compute expected returns and covariances for the next period
    cur_returns = data_prices(day_ind_start+1:day_ind_end,:) ./ data_prices(day_ind_start:day_ind_end-1,:) - 1;
    mu = mean(cur_returns)';
    Q = cov(cur_returns);

end

% Plot results
figure(1);
% daily value of portfolio
plot(1:N_days, portf_value{1}(1:N_days), '--ms'); % strategy 1
hold on;
plot(1:N_days, portf_value{2}(1:N_days), '-.r*'); % strategy 2
hold on;
plot(1:N_days, portf_value{3}(1:N_days), '-.ko'); % strategy 3
hold on;
plot(1:N_days, portf_value{4}(1:N_days)); % strategy 4
xlabel('trading day from 2005 to 2006');
ylabel('daily value of portfolio (USD)');
legend('Buy and Hold', 'Equally Weighted Portfolio', ...
    'Mininum Variance Portfolio', 'Maximum Sharpe Ratio Portfolio','Location','SouthEast'); % NorthEastOutside
% axis([0 503 0.4*10^6 1.4*10^6])

% two charts for strategy 3 and 4
weight2 = zeros(length(init_positions), N_periods);

weight3 = zeros(length(init_positions), N_periods);
weight4 = zeros(length(init_positions), N_periods);

weight2(:,1) = w_init;
weight3(:,1) = w_init;
weight4(:,1) = w_init;

for ii = 2:N_periods
    weight2(:,ii) = weight{2,ii};
    weight3(:,ii) = weight{3,ii};
    weight4(:,ii) = weight{4,ii};
end
% portfolio weights for stategy 3
figure(2);colormap(hsv);
% plot(1:N_periods, weight3);
bar(weight3(:,1:N_periods)','stacked');
legend(headers{1,1}(2:21),'Location','southeastoutside')
xlabel('periods');
ylabel('portfolio weights')
axis([0 N_periods+1 0 1])
title('strategy 3')


figure(3);colormap(hsv);
% plot(1:N_periods, weight4);
bar(weight4(:,1:N_periods)','stacked');
legend(headers{1,1}(2:21),'Location','southeastoutside')
xlabel('periods');
ylabel('portfolio weights')
title('strategy 4')
axis([0 N_periods+1 0 1])


% % here plots strategy 2 - this is not necessary
% figure(4);colormap(hsv);
% % plot(1:N_periods, weight4);
% bar(weight2(:,1:N_periods)','stacked');
% legend(headers{1,1}(2:21),'Location','southeastoutside')
% xlabel('periods');
% ylabel('portfolio weights')
% axis([0 N_periods+1 0 1])
% title('strategy 2')

% % here plots cash@each period of strategies 3 4 5  - which is not required in the assignment
% figure(5);
% cashAmount = zeros(N_strat-1,N_periods);
% for i_strate = 2:N_strat
%     for i_period = 1:N_periods
%         cashAmount(i_strate-1,i_period) = cash{i_strate,i_period};
%         
%     end
% end
% plot(1:N_periods, cashAmount);
% legend('Equally Weighted Portfolio', 'Mininum Variance Portfolio', 'Maximum Sharpe Ratio Portfolio')
% xlabel('periods')
% ylabel('cash amount')