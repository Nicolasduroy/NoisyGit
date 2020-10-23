clear;
%close all;
% Create  an  m-fileIR1.m that  conducts  a  simple  experiment  to  estimate
% the  impulse  response  (IR)  of  the  acoustic  channel,  by  literally 
% applying the definition of the IR (i.e., ‘the response of the system when 
% applying animpulse at the input’).  The m-file should plot a figure with
% two subplots containing the estimated IR response (time-domain), and the 
% (magnitude of the) frequency response. The time-domain scale must be in  
% samples(‘filter taps’), not seconds, and the frequency scale must be in Hz.
% The frequency response is plotted on a dB-scale (on the magnitude axis, 
% not on the frequency axis).  What do you observe?

% Initialization
fs = 16000;
dftsize = 2^10;

%Generate kroneckerdelta
% Also function kroneckerdelta: kroneckerDelta(m,n)
kroneckerdelta = [0; 0; 1; 0; 0];
noise = wgn(1, 2*fs, 1);

[simin, nbsecs, fs] = initparams(kroneckerdelta,fs);
sim('recplay');
impulseresponse = simout.signals.values;

[simin, nbsecs, fs] = initparams(transpose(noise),fs);
sim('recplay');
noise_out = simout.signals.values;

% pseudo-automatically select the appropriate part of the response (start)
[Maximum,index_max] = max(impulseresponse);
impulseresponse = impulseresponse(index_max - 50: index_max + 1000);

% pseudo-automatically select the appropriate part of the response (end)
% Take end as Maximum/100

% Or take it until amplitude noise ~ when amplitude approx. constant in time. 

[spectro_impulseresponse, f_impulseresponse, t_impulseresponse] = spectrogram(impulseresponse, dftsize, dftsize/2, dftsize, fs);
spectro_impulseresponse = abs(spectro_impulseresponse);
db_impulserespons = 20*log(spectro_impulseresponse);


convolution = fftfilt(impulseresponse, noise);
[spectro_convolution, f_convolution, t_convolution] = spectrogram(convolution, dftsize, dftsize/2, dftsize, fs);
[spectro_noise_out, f_noise_out, t_noise_out] = spectrogram(noise_out, dftsize, dftsize/2, dftsize, fs);
spectro_convolution = abs(spectro_convolution);
spectro_noise_out = abs(spectro_noise_out);
db_convolution = 20*log(spectro_convolution);
db_noise_out = 20*log(spectro_noise_out);

figure;
subplot(2,1,1);
    plot(impulseresponse);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Impulse response');
subplot(2,1,2);
    plot(f_impulseresponse,mean(db_impulserespons,2));
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse response (dB)');

figure;
imagesc(f_impulseresponse, t_impulseresponse, spectro_impulseresponse);
title('Spectrogram of Input');
xlabel('f (Hz)');
ylabel('t (s)');

figure;
subplot(4,1,1);
    plot(convolution);
    title('Time-domain convoluted');
    xlabel('Filter-taps');
    ylabel('conv');
subplot(4,1,2);
    plot(f_convolution,mean(db_impulserespons,2));
    title('Frequency-domain conv');
    xlabel('f (Hz)');
    ylabel('conv (dB)');
subplot(4,1,3);
    plot(noise_out);
    title('Time-domain recorded');
    xlabel('Filter-taps');
    ylabel('noise_out');
subplot(4,1,4);
    plot(f_noise_out,mean(db_impulserespons,2));
    title('Frequency-domain noise_out');
    xlabel('f (Hz)');
    ylabel('conv (dB)');

figure;
imagesc(f_convolution, t_convolution, spectro_convolution);
title('Spectrogram of convoluted');
xlabel('f (Hz)');
ylabel('t (s)');

figure;
imagesc(f_noise_out, t_noise_out, spectro_noise_out);
title('Spectrogram of recorded');
xlabel('f (Hz)');
ylabel('t (s)');
    
% 2.1.2 How long is the IR approximately?
%%%%%%%% 300-350 filtertaps

% 2.1.3  If  one  would  do  the  same  experiment  in  a  cathedral,  
% with  high-poweraudio equipment, and the distance between loudspeaker and 
% microphoneis larger than 20m, how would this IR change?
%%%%%%%%%% Much longer impulseresponse both better equimpent bigger room
%%%%%%%%%% (longer travelling distances reflections) also amplitude drops
%%%%%%%%%% slower because of the longer path of the straight signal itself.


% 2.1.4  Is  the  acoustical  environment  the  only  factor  that  determines  
% the  IR? What else can have an influence?
%%%%%%%%%% Amplitude of the impulse
%%%%%%%%%% Noise-factors (rumour and such)
%%%%%%%%%% ...

% 2.1.5 Optional:   First,  use IR1.m to  make  a  new  estimate  of  the  IR.  
% Then, without moving the microphone, repeat the white-noise experiment from
% exercise 1-2.  If you now convolve the transmitted white noise signal with
% the estimated IR (use the command fftfilt), this should yield an output signal 
% with similar characteristics as the recorded signal (why?).
%%%%%%%%%%% (First test) Approx same frequency-spectrum.
%%%%%%%%%%% IR1 is approximately the impulseresponse.

% Compare the spectrograms and PSDs of the recorded signal and the convolved signal.


%%%%% Do they look more or less the same?
%%%%% freq-spec does but it seems too much alike
