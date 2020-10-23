
% length_signal = 256;
% 
% inputsig = idinput(length_signal,'rbs');
% 
% inputsig = ceil((inputsig + 1)/2);
% 
% Nq = 4;
% M = 2^Nq;

function [qam_modulated, M] = qam_mod(inputsig, M)

qam_modulated = qammod(inputsig, M, 'InputType','bit');

end





