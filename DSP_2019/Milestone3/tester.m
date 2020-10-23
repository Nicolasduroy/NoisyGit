x = [1,2,3,4;1,2,3,4;1,2,3,4;1,2,3,4;1,2,3,4;1,2,3,4;]
k = [11;22;33;44;55;66]
[m,n] = size(x);
xk = [];
for i = 1:n
    xk(:,i) = [x(:,i);k]
end
xk = xk(:);
xk = reshape(xk, 6, 8);

xs = x(:);

y = x(2,1:4);

a = 20;
b= 7;
c = ~rem(a,b)

if ~mod(a,b) == 0
    a = 100
end