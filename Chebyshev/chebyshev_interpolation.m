% we use Chebyshev functions as basis to interpolate
% instead of polynomial interpolation with Chebyshev nodes

% functions used are implemented at the end.
f1 = @(x) abs(sin(6. * x)).^3. - cos(5. * exp(x)); 
f2 = @(x) 1./(1+25*x.^2) - sin(20. * x);


% then we can assemble the interpolation easily
% for a given n:
% C(f)(x) = sum ( 1 <= i <= n ) c(i) T(i-1,x) - 0.5 * c(1)

% we can choose different a and b other than -1 and 1
% ===== experiment 1: f1 
a = -2;
b = 2;
n = 50;
% m is the num of points used to draw the graph
% ofc we pick a big number
m = 500;
x = linspace(a, b, m);
interpolate(a, b, n, m, x, f1);

% ==== experiment 2: f2
interpolate(a, b, n, m, x, f2);

% ==== experiment 3: f2 with different a, b, and n
interpolate(0, 3, 40, 500, x, f2);

% ==== experiment 4: 
% take f1 and plot several n on the same graph
figure;
c = chebyshev_coefficients(a, b, 20, f1);
% evaluation at these points
y = f1(x);
res20 = evaluate(a, b, 20, m, c, x);

c = chebyshev_coefficients(a, b, 40, f1);
% evaluation at these points
res40 = evaluate(a, b, 40, m, c, x);
 
c = chebyshev_coefficients(a, b, 60, f1);
% evaluation at these points
res60 = evaluate(a, b, 60, m, c, x);

c = chebyshev_coefficients(a, b, 80, f1);
% evaluation at these points
res80 = evaluate(a, b, 80, m, c, x);

plot(x, y, x, res20, x, res40, x, res60, x, res80); title('Chebyshev Interpolations'); 
xlabel('x'); ylabel('value'); legend('f1','n = 20', 'n = 40', 'n = 60', 'n = 80','location','best')



% ==== experiment 5: error f1
% we'll see that the error goes down monotonously to near 0
y1 = f1(x);
error = zeros(1, 8);
for n = 10 : 10 : 80
    iteration_num = n / 10;
    interpolation_val = evaluate(a, b, n, m, c, x);
    max_error = max( abs( y1 - interpolation_val) );
    error(iteration_num) = max_error;
end

% plot max errors
n = 10: 10 : 80;
figure;
plot(n, error);
xlabel('order'); ylabel('maximum absolute error'); title('Max error');


%--------------------------functions----------------------------------------
% we took the following function to compute coeffs (citation in the annotations)
% notice that this is a discrete version of the coeffs 
function c = chebyshev_coefficients ( a, b, n, f )

%*****************************************************************************80
%
%% CHEBYSHEV_COEFFICIENTS determines Chebyshev interpolation coefficients.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    13 September 2011
%
%  Author:
%
%    John Burkardt
%
%  Reference:
%
%    Roger Broucke,
%    Algorithm 446:
%    Ten Subroutines for the Manipulation of Chebyshev Series,
%    Communications of the ACM,
%    Volume 16, Number 4, April 1973, pages 254-256.
%
%    William Press, Brian Flannery, Saul Teukolsky, William Vetterling,
%    Numerical Recipes in FORTRAN: The Art of Scientific Computing,
%    Second Edition,
%    Cambridge University Press, 1992,
%    ISBN: 0-521-43064-X,
%    LC: QA297.N866.
%
%  Parameters:
%
%    Input, real A, B, the domain of definition.
%
%    Input, integer N, the order of the interpolant.
%
%    Input, real F ( X ), a function handle.
%
%    Output, real C(N), the Chebyshev coefficients.
%
  angle = ( 1 : 2 : ( 2 * n - 1 ) ) * pi / ( 2 * n );
  angle = angle';
  x = cos ( angle );
  x = 0.5 * ( a + b ) + x * 0.5 * ( b - a );
  fx = f ( x );

  c = zeros ( n, 1 );
  for j = 1 : n
    c(j) = 0.0;
    for k = 1 : n
      c(j) = c(j) + fx(k) * cos ( pi * ( j - 1 ) * ( 2 * k - 1 ) / 2 / n );
    end
  end

  c(1:n) = 2.0 * c(1:n) / n;

  return
end
function eval = evaluate(a, b, n, m, c, x)
eval = zeros(1, m);
points = ( 2.0 * x - a - b ) / ( b - a );
for i = 1: 1 : n
    eval = eval + c(i) * chebyshevT(i - 1, points);
end
eval = eval - 0.5 * c(1);
return
end
function interpolate(a, b, n, m, x, f)
c = chebyshev_coefficients(a, b, n, f);
% evaluation at these points
y = f(x);
res = evaluate(a, b, n, m, c, x);
figure;
plot(x, y, x, res); title(['Chebyshev Interpolations at order ' num2str(n)]); xlabel('x');ylabel('value');
legend('function','chebyshev','location','best')
end


