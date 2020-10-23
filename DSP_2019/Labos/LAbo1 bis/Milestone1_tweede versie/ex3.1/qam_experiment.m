clear all;
close all;


for Nq = 4:4
    M = 2^Nq;

    length_signal = 100000;
    length_signal = length_signal*Nq;
    inputsig = randi( [0,1],length_signal, 1);

    [qam_modulated, M] = qam_mod(inputsig, M);

    nf = modnorm(qam_modulated,'peakpow',1);
    qam_modulated = qam_modulated*nf;
    % if Nq = 6
    %     qam_modulated = qam_modulated/(sqrt(2)*3);
    % elseif Nq = 4
    %     qam_modulated = qam_modulated/(sqrt(2)*3); % Nq = 4
    % elseif Nq = 3
    %     qam_modulated = qam_modulated/(sqrt(3)); % Nq = 3
    % elseif Nq = 2
    %     qam_modulated = qam_modulated/(sqrt(2)); % Nq = 2
    % end
    %qam_modulated = [real(qam_modulated), imag(qam_modulated)];
    with_noise = awgn(qam_modulated, 30);
    scatterplot(with_noise);
demodulated = qam_demod(with_noise/nf, M);

[BER,check] = ber(inputsig, demodulated, length_signal);

inputsig_decimal = bi2de2(inputsig, Nq, length_signal);
demodulated_decimal = bi2de2(demodulated, Nq, length_signal);
[BwER,check] = ber(inputsig_decimal, demodulated_decimal, length_signal/Nq);

%Bit error rate
BER
%Word error rate
BwER
end


% For 0.000% BER the SNR has to be at least:
% qam64 -> 29dB, qam32 -> 24dB, qam16 -> 21.5dB
% qam8 -> 19dB, qam4 -> 12dB, qam2 -> 12dB
