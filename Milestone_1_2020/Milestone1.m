clear all;
close all;

dftsize = 2^10;
fs = 16000;
T = 2;
t = 0: 1/fs: T;
sig = wgn(1, 2*fs, 1);

% set params, run simulink model and save output
[simin, nbsecs, fs] = initparams(transpose(sig),fs);
sim('recplay');
out = simout.signals.values;

%Make a spectrogram of the signal and the recorded signal
[spectro_in, f_in, t_in] = spectrogram(sig, dftsize, dftsize/2, dftsize, fs);
[spectro_out, f_out, t_out] = spectrogram(out, dftsize, dftsize/2, dftsize, fs);

%Convert to dB
spectro_in = transpose(10*log(abs(spectro_in)));
spectro_out = transpose(10*log(abs(spectro_out)));

%Plot spectrograms of the noise input and output
figure;
    subplot(2,1,1);
    imagesc(f_in, t_in, spectro_in);
    title('Spectrogram of Input');
    xlabel('f (Hz)');
    ylabel('t (s)');
subplot(2,1,2);
    imagesc(f_out, t_out, spectro_out);
    title('Spectrogram of Output');
    xlabel('f (Hz)');
    ylabel('t (s)');

%calculate psd of the noise input and output   
psd_in = transpose(mean(transpose(spectro_in),2));
psd_out = transpose(mean(transpose(spectro_out), 2));

% Plot the PSDs
figure;
subplot(2,1,1);
    plot(f_in, psd_in);
    title('PSD of Input');
    xlabel('f (Hz)');
    ylabel('PSD (J/Hz)');
subplot(2,1,2);
    plot(f_out, psd_out);
    title('PSD of Output');
    xlabel('f (Hz)');
    ylabel('PSD (J/Hz)');

    
    
    
    
    
%calcute impulse response based on convolution between input and output
T = toeplitz(sig(512:2*fs),flipud(transpose(sig(1:512)))); 
delay = finddelay(sig, out);
 
IR2 = T\out(delay+450:delay + 2*fs-512+450);

% Calculate the psd of the impulsresponse (IR1) 
[spectro_IR2, f_IR2, t_IR2] = spectrogram(IR2, dftsize/2, dftsize/4, dftsize/2, fs);
spectro_IR2 = abs(spectro_IR2);
db_IR2 = 20*log(spectro_IR2);

figure;
subplot(2,1,1);
    plot(IR2);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Impulse response');
subplot(2,1,2);
    plot(f_IR2,mean(db_IR2,2));
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse response (dB)');


% Analyze the channel by impuls-input (IR1)
kroneckerdelta = [0; 0; 1; 0; 0];

[simin, nbsecs, fs] = initparams(kroneckerdelta,fs);
sim('recplay');
impulseresponse = simout.signals.values;

% pseudo-automatically select the appropriate part of the response (start)
[Maximum,index_max] = max(impulseresponse);
IR1 = impulseresponse(index_max - 50: index_max + 1000);

% pseudo-automatically select the appropriate part of the response (end)
% Take end as Maximum + 1000
% Or take it until amplitude noise ~ when amplitude approx. constant in time. 

% Calculate the psd of the impulsresponse (IR1) 
[spectro_IR1, f_IR1, t_impulseresponse] = spectrogram(IR1, dftsize/2, dftsize/4, dftsize/2, fs);
spectro_IR1 = abs(spectro_IR1);
db_IR1 = 20*log(spectro_IR1);

figure;
subplot(2,1,1);
    plot(IR1);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Impulse response');
subplot(2,1,2);
    plot(f_IR1,mean(db_IR1,2));
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse response (dB)');
