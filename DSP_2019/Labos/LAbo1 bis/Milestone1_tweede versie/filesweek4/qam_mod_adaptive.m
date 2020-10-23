
% length_signal = 256;
% 
% inputsig = idinput(length_signal,'rbs');
% 
% inputsig = ceil((inputsig + 1)/2);
% 
% Nq = 4;
% M = 2^Nq;

function [qam_modulated, M] = qam_mod_adaptive(inputsig, b)
i = 1;
qam_modulated = [];
for k = 1:length(b)
    if b(k) > 0
        b(k)
        qam_mod_element = qammod(inputsig(i:i+b(k)-1), 2^b(k), 'InputType','bit'); 
        i = i + b(k)
    else
        qam_mod_element = [0]
    end 
    qam_modulated = [qam_modulated; qam_mod_element]; 
end
end





