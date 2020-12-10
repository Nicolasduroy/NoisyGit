%Yk = input, step = input, normalph = input, Wk_est = output
function [Xk_est, Wk_est] = DDequalization(Yk, step , normalph, Wk_start, M, fresp_h)
Wk = Wk_start;
i=1;
errplot=zeros(length(Yk),1);
while i<=length(Yk)
  filtout = Wk'*Yk(i);
  temp = qam_demod(filtout,M);  % demods to nearest symbol
  d = qam_mod(M,temp);          % mods again => right/absolute value
  err = d-filtout;
  Wk = Wk + (step/(normalph+Yk(i)'*Yk(i)))*Yk(i)*err';
%   errplot(i) = abs(Wk'-1/fresp_h);
  i=i+1;
end

Xk_est  = d;
Wk_est = Wk;

% if errplot(end) > 0.5
%     itt = linspace(1,length(Yk),length(Yk));
%     figure;
%     plot(itt, errplot);
% end
end