clear;
% 1.3.1 What is the useful frequency range that can be used by the acoustic modem?
% (Hint:google your hardware!)
%
% Velleman HSM 10: frequentierespons: 100Hz - 16kHz
% Loudspeakers: ?

% Initialization
dftsize = 2^10;
T = 2;
fs = 44100;
t = 0: 1/fs: T;
f = 400;
sig = transpose(sin(2*pi*f*t));
% 1.3.2 Shannon Capacity formula
% First record background noise, no signal
[simin, nbsecs, fs] = initparams(zeros(2*fs,1),fs);
disp('play without signal');
sim('recplay');
disp('done');
bgnoise_out = simout.signals.values;
[spectro_bgnoise, f_bgnoise, t_bgnoise] = spectrogram(bgnoise_out, dftsize, dftsize/2, dftsize, fs);

spectro_bgnoise = transpose(abs(spectro_bgnoise));
psd_bgnoise_out = mean(spectro_bgnoise, 1);

% Repeat, but with signal
[simin, nbsecs, fs] = initparams(sig,fs);
disp('play with signal');
sim('recplay');
disp('done');
signal_out = simout.signals.values;
[spectro_signal_out, f_signal_out, t_signal_out] = spectrogram(signal_out, dftsize, dftsize/2, dftsize, fs);

spectro_signal_out = transpose(abs(spectro_signal_out));
psd_signal_out = mean(spectro_signal_out, 1);

% psd signal = psd(signal + bgnoise) - psd bgnoise
psd_signal = abs(psd_signal_out - psd_bgnoise_out);

figure;
subplot(3,1,1);
    plot(f_signal_out, psd_signal_out);
    title('Signal and Noise');
    xlabel('f (Hz)');
    ylabel('PSD (J/Hz)');
subplot(3,1,2);
    plot(f_bgnoise, psd_bgnoise_out);
    title('Noise');
    xlabel('f (Hz)');
    ylabel('PSD (J/Hz)');
subplot(3,1,3);
    plot(f_signal_out, psd_signal);
    title('Signal');
    xlabel('f (Hz)');
    ylabel('PSD (J/Hz)');

% 1.3.3  With this m-file, determine the capacity of the acoustic channel, 
% assumin gfs= 16000 Hz, with distance between microphone and loudspeaker<10cm.

capacity = (fs/dftsize)*sum(log2(1+(psd_signal./psd_bgnoise_out)))
sumsum = sum((psd_signal./psd_bgnoise_out))
% 1.3.4 How does this number (channel capacity) need to be interpreted,
%%%%%%%%  bits per seconde

% i.e., what does it mean?
%%%%%%%%%%% Max amount of information that can be send through. 

%%%%%%%%%%% Higher frequency => higher BW => More reach for noise => lower
%%%%%%%%%%% SNR => Lower channel-capacity

% 1.3.5 Do the same for fs= 44100 Hz.
%%%%%%%%% Higher capacity for same bandwitdh

% 1.3.6 Extra (for the die-hards):  Determine how the capacity changes 
% with distance between loudspeaker and microphone, and make a dependency 
% plot.Save the plot as a mat-file (and an m-fileplotshannonvsdistance.m
% to actually plot it) and show it during the milestone demo (next week)