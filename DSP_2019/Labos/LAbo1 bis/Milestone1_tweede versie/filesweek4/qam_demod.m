function [demodulated] = qam_demod(qam_signal, M)
    %refpoints = (0:M-1);
    %refpoints = 2bin
    
    demodulated = qamdemod(qam_signal, M, 'outputtype', 'bit');
end