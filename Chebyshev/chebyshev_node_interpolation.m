f1 = @(x) abs(sin(6. * x)).^3. - cos(5. * exp(x)); % the first function
f2 = @(x) 1./(1+25*x.^2) - sin(20. * x);

% plot 2 functions over [-1,1];
x = -1:1e-3:1;
y1 = f1(x);
y2 = f2(x);
figure;
plot(x, y1, x, y2); title('functions'); xlabel('x');ylabel('y1 & y2');
error1 = zeros(1, 5);
error2 = zeros(1, 5);

for n = 20 : 20 : 100
iteration_num = n / 20;
k = 1:n; % iterator
xc = cos((2*k-1)/2/n*pi); % Chebyshev nodes
yc1 = f1(xc); % function evaluated at Chebyshev nodes
yc2 = f2(xc);
hold on;
plot(xc, yc1,'o');
plot(xc, yc2,'*');

% find polynomial to interpolate data using the Chebyshev nodes
p1 = polyfit(xc, yc1, n-1); 
p2 = polyfit(xc, yc2, n-1); 
max_error1 = max( abs( y1 - polyval(p1, x) ) );
max_error2 = max( abs( y2 - polyval(p2, x) ) );
error1(iteration_num) = max_error1;
error2(iteration_num) = max_error2;

plot(x, polyval(p1,x), '--'); % plot polynomial
plot(x, polyval(p2,x), '-.');
legend('f1 = |sin(6x)|^3 - cos(5e^x)', 'f2 = 1/(1 + 25x^2) - sin(20x)', ...
    'f1 nodes', 'f2 nodes','Chebyshev of f1','Chebyshev of f2', 'location','best')

figure;
plot(x, abs(y1-polyval(p1,x)), x, abs(y2-polyval(p2,x))); 
xlabel('x');ylabel('|f1 - p1| & |f2 - p2|');title(['Error when n = ' num2str(n)]);
end

% finally, we plot how the max error changes 
n = 20: 20 : 100;
figure;
plot(n, error1, n, error2);
xlabel('num of Chebyshev points'); ylabel('maximum absolute error'); title('Max error');
legend('f1','f2','location','best')

