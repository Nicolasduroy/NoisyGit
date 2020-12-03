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

Streamblock = randi([0 1], 500*trainblock_length, 1);

trainblock = randi([0 1], trainblock_length, 1);

qamtrainblock = qam_mod(M,trainblock);
qamStream = qam_mod(M,Streamblock);

cpr = fftSize/2;
Lt = 5;
Ld = 19;
qamtrain = [];

Tx = ofdm_mod(qamStream, qamtrainblock, frameSize, fftSize, cpr, Ld, Lt);

load("IRest.mat");
impRespCh = h;
t = linspace(0,500,500);

fresp_h = fft(h, fftSize);
f = linspace(0, fs/2, fftSize);

figure;
subplot(2,1,1);
    plot(t, h);
    title('impulseresponse time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h);
    title('impulseresponse frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

    
Rx = fftfilt(impRespCh,Tx);
% pulse = [0; 1; 1; 1; 0];
% IRlength = 511;
% [simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
% sim('recplay');
% out = simout.signals.values;

% Rx = alignIO(out, pulse, IRlength);

% OFDM-demodulate
[receivedQam, fresp_est] = ofdm_demod(Rx, fftSize, cpr, qamtrainblock, fs, Lt, Ld);

h_est = ifft(fresp_est, fftSize);
t_est = linspace(0,1024,1024);

figure;
subplot(2,1,1);
    plot(t_est, h_est);
    title('Estimate of impulseresponse: time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_est);
    title('Estimate of impulseresponse: frequency-domain');
    xlabel('frequency');
    ylabel('Imulse Response amplitude');

% QAM-demodulate
receivedSeq = qam_demod(receivedQam(:,1),M);
received_trainblock = receivedSeq(1+0*frameSize*Nq:1*frameSize*Nq);

% calculate BER
ber = ber(received_trainblock, trainblock);