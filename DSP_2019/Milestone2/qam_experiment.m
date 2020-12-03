clear;
close all;

% 1. Generate a pseudo random binary sequence of a user defined length.
% 2. Create a Matlab function qam mod.m that modulates a sequence of bits into M-ary QAM format
% where M is by definition an integer power of 2 i.e., M = 2Nq . The maximum value of Nq for the
% target OFDM system will be 6, corresponding to 64-QAM.

length = 5000;
Nq = 6;
M = 2^Nq;

% make sure length is a multiple of Nq
length = ceil(length/Nq)*Nq;

sequence = randi([0 1], length, 1);
qamModSeq = qam_mod(M,sequence);

%3. Check the constellation diagram for the generated QAM symbol sequence.
scatterplot(qamModSeq);

%4. Compare the QAM symbol sequences for different constellation sizes. What are their average 
% signal powers? Make sure that the constellations yielded by qam mod.m are normalized to unit 
% signal power. What are the normalization factors for the different constellation sizes?

avgSigPow = mean(abs(qamModSeq).^2,1);
norQamModSeq = qamModSeq/sqrt(avgSigPow); %Average power over all symbols is one
scatterplot(norQamModSeq);
title('Normalized QAM');

% 5. Now put additive white Gaussian noise (AWGN) on the QAM symbolsequence and again check the
% constellation diagram. What are the trade-offs of using different constellation sizes?

% bit rate or spectral efficiency ~ constellation size
% 16 QAM: 4 bits per symbol, 64 QAM: 6 bits per symbol
% but the bigger the constellation size, the more prone to noise (higher BER)

SNR = 50;
AwgnNorQamModSeq = awgn(norQamModSeq, SNR);
scatterplot(AwgnNorQamModSeq);
title('AWGN QAM');

% 6. Create a Matlab function qam demod.m that demodulates a QAM symbol 
% sequence back to a binary sequence for different values for M. Call this function from within
% the qam experiment.m script to demodulate the noisy QAM symbols back to bits.

AwgnNorQamModSeq = sqrt(avgSigPow)*AwgnNorQamModSeq;
receivedSeq = qam_demod(AwgnNorQamModSeq,M);
% 7 Create a Matlab function ber.m that takes two binary sequences (a transmitted sequence and
% a received sequence) and calculates the so-called biterror rate (BER). Call this function from
% within the qam experiment.mscript and check the BER for different M-ary QAM constellations, 
% and different signal-to-noise ratios (SNR).   

difference = abs(sequence-receivedSeq);
figure('name','Difference between received and transmitted sequence.');
stem(difference,'LineStyle','none','color','red');
bitErrorRate = ber(sequence, receivedSeq);