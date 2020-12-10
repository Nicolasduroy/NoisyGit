% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.



%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = ofdm_demod(ofdmSeq, fftSize, cpr, Lt, M, fresp_h)

%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize); % Per row 1 frequency

%% Division into training- and dataframes according to Lt and Ld
% first do for every freq: DDequalization for trainingframes
% First Lt columns are the trainingframes
Wk = zeros(length(fd_packet(1,:)), 1);
step = 0.1;
normalph = 0.5;
Hk_start = 1*((rand(1)-0.5) + (rand(1)-0.5)*1i);
Wk_start = (1/(Hk_start'));
demodulated = [];
%% Training
[~, Wk(1)] = DDequalization(fd_packet(1,1:Lt), step, normalph, Wk_start, M, fresp_h(1));
[~, Wk(2)] = DDequalization(fd_packet(2,1:Lt), step, normalph, Wk_start, M, fresp_h(2));
for r = 3 : fftSize % per tone => per column => fftSize
    rprint = r
    [~, Wk(r)] = DDequalization(fd_packet(r,1:Lt), step, normalph, Wk(r-1), M, fresp_h(r)); % Wk(r-1) bc assume fluent spectrum
end

%% Data
[ ~ ,amnt_columns] = size(fd_packet); % Should be equal to P
% Asses size of demodSeq before for speedup
if P > Lt
    for c = Lt+1 : amnt_columns 
        for r2 = 2 : fftSize/2 % per tone => per column => 2:fftSize/2 because only necessary symbols needed (pleonasm)
            [X_est, Wk(r2)] = DDequalization(fd_packet(r2,c), step, normalph, Wk(r2), M);
            demodulated = [demodulated; X_est];
        end
    end
    demodulatedSequence = demodulated;
% else
%     demodulatedSequence = [];
end
fresp_est = Wk;
end
