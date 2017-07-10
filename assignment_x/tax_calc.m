clc;
clear all;
format long

% Input files
input_file_prices  = 'prices.csv';
input_file_purchases = 'purchases.csv';

% Read transactions
if(exist(input_file_purchases,'file'))
  fprintf('\nReading transcactions datafile - %s\n', input_file_purchases)
  fid1 = fopen(input_file_purchases);
     % Read item names
     hheader  = textscan(fid1, '%s', 1, 'delimiter', '\n');
     headers = textscan(char(hheader{:}), '%q', 'delimiter', ',');
     items = headers{1}(2:end);
  fclose(fid1);
  purchases = dlmread(input_file_purchases, ',', 1, 1);
  % Remove empty transactions
  purchases = purchases(find(sum(purchases')),:);
else
  error('Transactions datafile does not exist')
end

% Read prices
if(exist(input_file_prices,'file'))
  fprintf('Reading prices datafile - %s\n', input_file_prices)
  cur_prices = dlmread(input_file_prices, ',', 1, 0);
  cur_prices = cur_prices';
else
  error('Prices datafile does not exist')
end

% Compute new prices
new_prices = tax_algorithm(cur_prices, purchases);

% the following algorithm is slow
% new_prices = tax_algorithm2(cur_prices, purchases);

% Compute percentage of the historical transactions that cleanly rounds to a 0 or a 5
cur_purchases = 1.13*(purchases * cur_prices);
new_purchases = 1.13*(purchases * new_prices);
perc_round_cur = sum(mod(round(100*cur_purchases), 5)==0) / size(purchases,1);
perc_round_new = sum(mod(round(100*new_purchases), 5)==0) / size(purchases,1);

fprintf('\n   ITEM     CUR PRICE   NEW PRICE    PRICE ADJ\n')
for(i=1:length(cur_prices))
    fprintf('%10s \t %6.2f \t %6.2f \t %6.2f\n', char(items(i)), cur_prices(i), new_prices(i), new_prices(i)-cur_prices(i))
end

fprintf('\n Current prices: percentage of transcations that cleanly round to 0 or 5  = %6.2f %%\n', 100*perc_round_cur);
fprintf('     New prices: percentage of transcations that cleanly round to 0 or 5  = %6.2f %%\n', 100*perc_round_new);