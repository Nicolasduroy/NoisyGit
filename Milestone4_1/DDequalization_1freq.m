clear all;
close all;
Nq = 4;
M = 2^Nq;
inputlength = 1000;
inputsig = randi([0 1], inputlength, 1);
Xk = qam_mod(M,inputsig);

Hk = 1*((rand(1)-0.5) + (rand(1)-0.5)*1i);
Yk = Hk*Xk;
Wk = (1/(Hk'))*(1-0.3);
normalph = 0.5;
step = 0.1;
i=1;
errplot=zeros(inputlength/Nq,1);
while i<=inputlength/Nq
  filtout = Wk'*Yk(i);
  temp = qam_demod(filtout,M);
  d = qam_mod(M,temp);
  err = d-filtout;
  Wk = Wk + (step/(normalph+Yk(i)'*Yk(i)))*Yk(i)*err';
  errplot(i) = abs(Wk'-1/Hk);
  i=i+1;
end

itt = linspace(1,inputlength/Nq,inputlength/Nq);

plot(itt, errplot);