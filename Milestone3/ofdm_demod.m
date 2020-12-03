% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.



%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = ofdm_demod(ofdmSeq, fftSize, cpr, qamtrainblock, fs, Lt, Ld)

%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr);
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize);

qamvector = [0;qamtrainblock;0;flipud(conj(qamtrainblock))];

%% Division into training- and dataframes according to Lt and Ld


% Training
fresp_est = zeros(fftSize, 1);
for i = 1:fftSize
    qamvalue = qamvector(i) + zeros(Lt,1);
    fresp_est(i) = qamvalue\transpose(fd_packet(i,:));
end

%Data
for i=1:P
  fd_packet(:,i) = fd_packet(:,i)./fresp_est; 
end

fd_packet = fd_packet(2:fftSize/2,:); %%% Get rid of the redundant symbols

demodulatedSequence = reshape(fd_packet,qamNo*P,1);



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
