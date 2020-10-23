clear all;
close all;

fs = 16000;
Nq = 2;
M = 2^Nq;
fftSize = 2^10; %% DFTsize N

%% Trainblock needed of N/2-1 QAM_symbols
%% Nq bits per QAM => trainblock heeft lengte (N/2-1)*Nq

frameSize = fftSize/2-1;

trainblock_length = frameSize*Nq;

trainblock = randi([0 1], trainblock_length, 1);

qamtrainblock = qam_mod(M,trainblock);

cpr = 100;
Lt = 1;
Ld = 1;
qamtrain = [];

for i = 1:cpr
   qamtrain = [qamtrain; qamtrainblock]; 
end

Tx = ofdm_mod(qamtrain, frameSize, cpr);

load("IRest.mat");
impRespCh = h;

[spectro_impRespCh, f_impRespCh, t_impRespCh] = spectrogram(impRespCh, 2^8, 2^7, fftSize, fs);
spectro_impRespCh = transpose(mean(20*log(abs(spectro_impRespCh)),2));

% figure;
% subplot(2,1,1);
%     plot(impRespCh);
%     title('Time-domain IR');
%     xlabel('Filter-taps');
%     ylabel('Imulse Response');
% subplot(2,1,2);
%     plot(f_impRespCh, spectro_impRespCh);
%     title('Frequency-domain IR');
%     xlabel('f (Hz)');
%     ylabel('Impulse Response (dB)');
    
% Rx = fftfilt(impRespCh,ofdmtrain);
pulse = [0; 1; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength);

% OFDM-demodulate
[receivedQam, fresp_est] = ofdm_demod(Rx, fftSize, cpr, qamtrainblock, fs, impRespCh, Lt, Ld);

% QAM-demodulate
receivedSeq = qam_demod(receivedQam(:,1),M);
received_trainblock = receivedSeq(1+0*frameSize*Nq:1*frameSize*Nq);

% calculate BER
ber = ber(received_trainblock, trainblock);