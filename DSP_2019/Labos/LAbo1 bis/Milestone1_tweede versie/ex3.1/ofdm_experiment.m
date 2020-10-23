clear all;
close all;


Nq = 2;
M = 2^Nq;
L = 4;

length_signal = 24;
length_signal = length_signal*Nq;
inputsig = randi( [0,1],length_signal, 1);

[qam, M] = qam_mod(inputsig, M);

nf = modnorm(qam,'peakpow',1);
qam = qam*nf;

P = 6;
ofdm = ofdm_mod(qam, P, length_signal/Nq, L);

%%%%%%%%%%% H(z) = 1 and SNR = infinty

demod = ofdm_demod(ofdm, P, length_signal/Nq, L);

check2 = sum(qam-demod);

outputsig = qam_demod(demod, M);

check3 = sum(abs(inputsig - outputsig))/length_signal;




