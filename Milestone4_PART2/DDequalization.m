%Yk = input, step = input, normalph = input, Wk_est = output
function [Xk_est, Wk_est] = DDequalization(Yk, step , normalph, Wk_start, M, trainsymbol, Train)
Wk = Wk_start;
i=1;
errplot=zeros(length(Yk),1);
while i<=length(Yk)
  filtout = Wk'*Yk(i);
  temp = qam_demod(filtout,M);  % demods to nearest symbol
  if Train == 1
    d = trainsymbol;
  else
    d = qam_mod(M,temp);        % mods again => right/absolute value
  end
  err = d-filtout;
  Wk = Wk + (step/(normalph+Yk(i)'*Yk(i)))*Yk(i)*err';
  i=i+1;
end

Xk_est  = d;
Wk_est = Wk;

end