% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.



%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = ofdm_demod(ofdmSeq, fftSize, cpr, Lt, M, trainblock)
ofdmSeq = ofdmSeq/max(abs(ofdmSeq));
%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize); % Per row 1 frequency

qamvector = [0;trainblock;0;flipud(conj(trainblock))];

%% Division into training- and dataframes according to Lt and Ld
% first do for every freq: DDequalization for trainingframes
% First Lt columns are the trainingframes
Wk = zeros(fftSize, 1);
step = 0.3;
normalph = 0.5;
demodulated = [];
%% Training
Hk = zeros(fftSize, 1);
for r = 1:fftSize
    qamvalue = qamvector(r) + zeros(Lt,1);
    Hk(r) = qamvalue\transpose(fd_packet(r,1:Lt));
    Wk(r) = (1/(Hk(r)'));
end

%% Data
[ ~ ,amnt_columns] = size(fd_packet); % Should be equal to P
% Asses size of demodSeq before for speedup
if P > Lt
    for c = Lt+1 : amnt_columns 
        for r2 = 2 : fftSize/2 % per tone => per column => 2:fftSize/2 because only necessary symbols needed (pleonasm)
            [X_est, Wk(r2)] = DDequalization(fd_packet(r2,c), step, normalph, Wk(r2), M, qamvector(1), 0);
            demodulated = [demodulated; X_est];
        end
    end
    demodulatedSequence = demodulated;
else
    demodulatedSequence = [];
end
fresp_est = Hk;
end
