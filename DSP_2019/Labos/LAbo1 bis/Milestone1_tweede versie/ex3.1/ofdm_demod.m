function [qamdemod] = ofdm_demod(ofdm, P, lengthqam, L)
N = lengthqam/P;
% Remove cyclic prefix 
ofdm = ofdm(L+1:2*N+L+2, 1:P);

% Find qam_modulation by fft
qamd = fft(ofdm);

qamdemod = [];
N = lengthqam/P;
for p = 1:P
    qamdemod = [qamdemod;qamd(2:N+1,p)];
    
end
