function gradValue = computeGradERC (x,Q)
  
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
