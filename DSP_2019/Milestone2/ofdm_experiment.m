clear all;
close all;

Nq = 4;
M = 2^Nq;
fftSize = 2^10;

frameSize = fftSize/2-1;
seqLength = 50000;

seqLength = ceil(seqLength/(Nq*frameSize))*Nq*frameSize;

sequence = randi([0 1], seqLength, 1);

qamModSeq = qam_mod(M,sequence);

cpr = 100;
ofdmModSeq = ofdm_mod(qamModSeq, frameSize, cpr);

% Add Additive White Gaussian Noise
SNR = 10;
receivedOfdm = awgn(ofdmModSeq, SNR);

impulseResponseChannel = zeros(200,1);
% OFDM-demodulate

receivedQam = ofdm_demod(receivedOfdm, fftSize, cpr, impulseResponseChannel);

% QAM-demodulate
receivedSeq = qam_demod(receivedQam,M);

% calculate BER
ber = ber(receivedSeq, sequence);

% 5 Find an expression for the data rate R of this OFDM system, i.e. the
% number of bits from the generated binary sequence that will be transmitted
% per second. Assume that all QAM symbols are drawn from an M-ary
% QAM constellation, that the modem sampling rate (i.e, the number of
% samples in the time-domain transmitted per second) is given by fs, that
% N denotes the DFT-size, and that L is the cyclic prefix length.
% Hint: the data rate is equal to the product of the following factors:
% (a) the number of encoded bits per QAM symbol;
% (b) the number of QAM symbols per OFDM frame;
% (c) the number of OFDM frames transmitted per second.

% 6 Evaluate the performance of the obtained OFDM communication chain for AWGN:
% (a) Add AWGN to the receiver input signal. The SNR is user defined.
% (b) Compare the BER obtained for different QAM constellations at a given SNR.
% (c) Run the same experiment for different SNRs.
