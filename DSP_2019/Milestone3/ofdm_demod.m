% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.

%%%%%%%%% Estimate channel impResp per frequency point %%%%%%%%%%%%%%%%%%%%
%%%%% First frequency-point is second row in fd_packet
%%%%% Last frequency-point is row 512 of fd_packet
%%%%% All symbols of same frequency-point correspond to sam qam-symbol
%%%%% Deviation between symbols in fd_packet and corresponding qam gives
%%%%% phase and amplitude deviation

%%%%% Als de cpr lang genoeg is dan zal de uitsmering van de channel niet
%%%%% tussen de frames overlopen en zal in output frame 1 gelijk zijn aan
%%%%% frame 2 enz.

%%%%% Methode om h_est te vinden met toeplitz te gebruiken moet in
%%%%% tijdsdomein, dit moet dus voor de fft gebeuren.

%%%%% zie slide 29/40
function [demodulatedSequence, estimate] = ofdm_demod(ofdmSeq, fftSize, cpr,qamtrainblock, fs, impRespCh, Lt, Ld)
%%%%%%%%%init values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = length(ofdmSeq)/(fftSize+cpr);
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%serial->parallel, remove prefix, transorm to freq-domain %%%%%%%%%%%
packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
T = toeplitz(qamtrainblock); 
% hier moet keuze training of niet komen.
% for loop met i tot lengthe packet
% Als (i+Lt) deelbaar is door (Lt+Ld) dan zullen de "volgende met deze erbij" 
% Lt frames training frames zijn en moet voorgaande worden toegepast.
%%%% Choose when its a training frame:
%%%% eerste Lt frames, dan LD frames data, dan terug Lt frames:
for jj = 1:P
    estimate = [];
    if ~mod(jj,Lt+Ld) == 1
        for ii = jj:jj+Lt
            rec_qamtrain = packet(ii(1:framesize);
            estimate(i) = T\rec_qamtrain;    
        end
        jj = jj + Lt;
        fresp_estimate = fft(estimate(1),fftSize);
    else
        fd_packet(:,i) = fft(packet(:,i), fftSize);
        fd_packet(:,i) = fd_packet(:,i)./fresp_estimate;
        demodulatedSequence = [demodulatedSequence;fd_packet(:,i)]
    end  
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Estimate channel impResp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Create toeplitz with known input-signal                        %%
%%%%%%%%% Extract received signal                                        %%
%%%%%%%%% Least-squares method                                           %%
%%%%%%%%% Calculate freq-spectrum                                        %%
% T = toeplitz(qamtrainblock);                              %%
% received_train = fd_packet(2:512,1);                                     %%
% h_est = T\received_train;                                                %%
% [spectro_est, f_est, t_est] = spectrogram(h_est, 2^8, 2^7, fftSize, fs); %%
% spectro_est = transpose(mean(20*log(abs(spectro_est)),2));               %%
% fresp_est = fft(h_est,fftSize); %% should be = f_est                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;
% subplot(2,1,1);
%     plot(h_est);
%     title('Time-domain estimate IR');
%     xlabel('Filter-taps');
%     ylabel('Imulse Response');
% subplot(2,1,2);
%     plot(f_est, 1:1024);
%     title('Frequency-domain estimate IR');
%     xlabel('f (Hz)');
%     ylabel('Impulse Response (dB)');
%%%%%%%% equalize channel by f_est, extract received, parallel->serial %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
