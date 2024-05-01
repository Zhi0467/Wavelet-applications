f1 = @(x) abs(sin(6. * x)).^3. - cos(5. * exp(x)); % the first function
f2 = @(x) 1./(1+25*x.^2) - sin(20. * x);

% we use a finer n list
% plot 2 functions over [-1,1];
x = -1:1e-3:1;
y1 = f1(x);
y2 = f2(x);
figure;
plot(x, y1, x, y2); title('functions'); xlabel('x');ylabel('y1 & y2');
error1 = zeros(1, 9);
error2 = zeros(1, 9);

for n = 20 : 10 : 100
iteration_num = n / 10 - 1;
k = 1:n; % iterator
xc = cos((2*k-1)/2/n*pi); % Chebyshev nodes
yc1 = f1(xc); % function evaluated at Chebyshev nodes
yc2 = f2(xc);

p1 = polyfit(xc, yc1, n-1); 
p2 = polyfit(xc, yc2, n-1); 
max_error1_poly = max( abs( y1 - polyval(p1, x) ) );
max_error2_poly = max( abs( y2 - polyval(p2, x) ) );
error1(iteration_num) = max_error1_poly;
error2(iteration_num) = max_error2_poly;
end


% polyfit and changing degree 
n = 20: 10 : 100;
figure;
plot(n, error1, n, error2);
xlabel('num of Chebyshev points'); ylabel('maximum absolute error'); title('Max error with polyfit and degree n - 1');
legend('f1','f2','location','best')

error1 = zeros(1, 9);
error2 = zeros(1, 9);

for n = 20 : 10 : 100
iteration_num = n / 10 - 1;
k = 1:n; % iterator
xc = cos((2*k-1)/2/n*pi); % Chebyshev nodes
yc1 = f1(xc); % function evaluated at Chebyshev nodes
yc2 = f2(xc);

p1 = polyfit(xc, yc1, 40); 
p2 = polyfit(xc, yc2, 40); 
max_error1_poly = max( abs( y1 - polyval(p1, x) ) );
max_error2_poly = max( abs( y2 - polyval(p2, x) ) );
error1(iteration_num) = max_error1_poly;
error2(iteration_num) = max_error2_poly;
end

% polyfit and fixed degree 40
n = 20: 10 : 100;
figure;
plot(n, error1, n, error2);
xlabel('num of Chebyshev points'); ylabel('maximum absolute error'); title('Max error with polyfit and fixed degree 40');
legend('f1','f2','location','best')




