
close all;
clear all;

Nq = 2;
M = 2^Nq;
inputlength = 1000;
inputsig = randi([0 1], inputlength, 1);
Xk = qam_mod(M,inputsig);

Hk = (1) + (1)*1i;
Yk = Hk*Xk;
Wk = (1/(Hk'))*(1+1);
normalph = 0.5;
stepsize = 0.1;
i=1;
errplot=zeros(inputlength/Nq,5);
for j = 1:5
    step = stepsize * j;
    while i<=inputlength/Nq
      filtout = Wk'*Yk(i);
      temp = qam_demod(filtout,M);
      d = qam_mod(M,temp);
      err = d-filtout;
      Wk = Wk + (step/(normalph+Yk(i)'*Yk(i)))*Yk(i)*err';
      errplot(i,j) = abs(Wk'-1/Hk);
      i=i+1;
    end
    i=1;
    Wk = (1/(Hk'))*(1+1);
end
for j = 1:5
    hold on
    title('Error between filter coefficient and channel coefficient for different step sizes');
    xlabel('Number of iterations')
    ylabel('Absolute value of error between filter coefficient and channel coefficient')
    plot(errplot(1:100,j))
    legend('Step size: 0.1','Step size: 0.2','Step size: 0.3','Step size: 0.4','Step size: 0.5')
end