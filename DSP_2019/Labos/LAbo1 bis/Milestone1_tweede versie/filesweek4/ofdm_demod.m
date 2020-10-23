function [qamdemod] = ofdm_demod(ofdm, P, lengthqam, L, h, fftSize)
N = lengthqam/P;
% Remove cyclic prefix 
ofdm = ofdm(L+1:2*N+L+2, 1:P);

% Find qam_modulation by fft
qamd = fft(ofdm, fftSize);

fresp = fft(h, fftSize);

qamdemod = [];
for p = 1:P
    qamd(:,p) = qamd(:,p)./fresp;
    qamdemod = [qamdemod;qamd(2:N+1,p)];   
end

end