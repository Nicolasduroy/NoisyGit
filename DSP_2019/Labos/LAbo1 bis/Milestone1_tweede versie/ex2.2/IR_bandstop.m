clear;

% Initialization
fs = 16000;
dftsize = 2^10;
sig = transpose(wgn(1,2*fs,1));

bandstop = fir1(60, [0.0875 0.375], 'stop');
% figure;
% freqz(bandstop);

sig = filter(bandstop, 1, sig);

[simin, nbsecs, fs] = initparams(sig,fs);
sim('recplay');
out = simout.signals.values;

[spectro_out, f_out, t_out] = spectrogram(out, dftsize, dftsize/2, dftsize, fs);
spectro_out = transpose(abs(spectro_out));
psd_out = mean(spectro_out, 1);

% cfr chapter 3, slide 17
T = toeplitz(sig(500:2*fs),flipud(sig(1:500)));
% using cross correlation to find the delay between sig and out
delay = finddelay(sig, out);
% \ will solve in a least squares way if overdetermined
h = T\out(delay+400:delay + 2*fs-100); 

[spectro_h, f_h, t_h] = spectrogram(h,2^8,2^7,dftsize,fs);
spectro_h = transpose(mean(20*log(abs(spectro_h)),2));


figure;
subplot(2,1,1);
    plot(h);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Imulse Response');
subplot(2,1,2);
    plot(f_h,spectro_h);
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse Response (dB)');

% figure;
% imagesc(f_h, t_h, spectro_h);
% title('Spectrogram of IR2');
% xlabel('f (Hz)');
% ylabel('t (s)');

%Save estimated impulse response to a file
save('IRest.mat','h');



% Repeat the IR estimation procedure a couple of times (now using IR bandstop.m),
% without moving the microphone inbetween the experiments. Is there a difference 
% with the results from exercise 2-2? Does the shape of the frequency response 
% now change a lot over the di?erent experiments? Can you explain this?
%%%%% The IR_bandstop seems to change a lot more



