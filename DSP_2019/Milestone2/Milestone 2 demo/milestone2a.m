% Milestone 2b - Corneel T Jonck and Vincent Vanweddingen (groep 5)

clear all;
close all;

% compute the BER vs SNR curves for different QAM constellation sizes plotted in one figure.
% For this you should use the qam experiment.m file of Exercise 3-1.

BER = zeros(100,6);
SNR = [0.25:0.25:25];

% Let the constellation size go from 2^1 to 2^6
for Nq = 1:6
    M = 2^Nq;
    length = 50000;
    %length should be multiple of Nq
    length = ceil(length/Nq)*Nq;
    sequence = randi([0 1], length, 1);
    
    for n = 1:100
        % normalized QAM mod
        qamModSequence = qam_mod(M,sequence);
        avgSigPow = mean(abs(qamModSequence).^2,1);
        normalizedQamModSequence = qamModSequence/sqrt(avgSigPow);
        
        % Additive White Gaussian Noise
        % bigger constellation: more prone to noise (higher BER)
        AwgnNormalizedQamModSequence = awgn(normalizedQamModSequence,SNR(n));
        
        % scaling + demod
        qamModAwgn = sqrt(avgSigPow)*AwgnNormalizedQamModSequence;
        receivedSequence = qam_demod(qamModAwgn,M);
        
        % Bit error rate
        BER(n,Nq) = ber(sequence,receivedSequence);
    end
end

figure;
plot(SNR,BER);
title('BER versus SNR for various QAM constellation sizes');
xlabel('SNR [dB]');
ylabel('Bit Error Rate');
legend('2-QAM','4-QAM','8-QAM','16-QAM','32-QAM','64-QAM');