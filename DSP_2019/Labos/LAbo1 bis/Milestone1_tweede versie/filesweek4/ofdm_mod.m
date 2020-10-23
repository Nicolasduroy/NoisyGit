function [ofdm] = ofdm_mod(qam, P, length_qam, channel_length, fftSize)
ofdm =[];
N = length_qam/P;

% Set up different ofdm frames
for p = 0:P-1
    data = qam(p*N+1:(p+1)*N);
%     Verkrijgen van enkel reële waarden na transformatie
    column = [0;data;0;flipud(conj(data))];
    ofdm = [ofdm,column];  
end

% Obtain time-domain signal segmants to send through
ofdm = ifft(ofdm, fftSize);

% set up cyclic prefix per dataframe
ofdm = [ofdm(2*N-channel_length+3:2*N+2, 1:P);ofdm];
end