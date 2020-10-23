clear;
close all;
% 2.2.1 How do the transmitted signalnal u[k], the (unknown) channel IR-vector h,
% and the recorded signalnaly[k] relate to each other (assuming that noise can
% be  neglected)?   Give  a  matrix  description  of  this  relation  (in  
% the  timedomain).  This yields an overdetermined system of linear equations, 
% where the  vectorhcontains  the  unknown  variables.   The  data  matrix  in  
% this system  of  equations  will  have  a  so-called  Toeplitz  structure  
% to  model  aconvolution.

% 2.2.2 Create  an  m-file IR2.m that  estimates  the  IR h based  on  this 
% matrix description, i.e., by solving the overdetermined system of equations 
% in a least  squares  sense.   What  dimension  should  you  choose  for h
% (use  the knowledge obtained in exercise 2-1)?  Use white noise as input 
% signalnalu[k]. Similar to IR1.m, the m-file IR2.m should make a plot of the 
% estimated IRresponse (time-domain), and the (magnitude of the) frequency 
% response.In addition, it should save the IR estimatehas a mat-file IRest.mat

% Initialization
fs = 16000;
dftsize = 2^10;
signal = transpose(wgn(1,2*fs,1));

[simin, nbsecs, fs] = initparams(signal,fs);
sim('recplay');
out = simout.signals.values;

[spectro_out, f_out, t_out] = spectrogram(out, dftsize, dftsize/2, dftsize, fs);
spectro_out = transpose(abs(spectro_out));
psd_out = mean(spectro_out, 1);

% cfr chapter 3, slide 17
T = toeplitz(signal(500:2*fs),flipud(signal(1:500))); %Its 2*fs cause the noise-input is 2*fs stop asking questions
% using cross correlation to find the delay between signal and out
delay = finddelay(signal, out);
% \ will solve in a least squares way if overdetermined
h = T\out(delay+400:delay + 2*fs-100); 

[spectro_h, f_h, t_h] = spectrogram(h,2^8,2^7,2^8,fs);
spectro_h = abs(transpose(mean(20*log(abs(spectro_h)),2)));
db_impulse_response = 20*log(spectro_h);


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


figure;
subplot(2,1,1);
    plot(signal);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Imulse Response');
subplot(2,1,2);
    plot(f_h,spectro_h);
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse Response (dB)');
    
convolution = fftfilt(h, signal);
[spectro_convolution, f_convolution, t_convolution] = spectrogram(convolution, dftsize, dftsize/2, dftsize, fs);
[spectro_noise_out, f_noise_out, t_noise_out] = spectrogram(out, dftsize, dftsize/2, dftsize, fs);
spectro_convolution = abs(spectro_convolution);
spectro_noise_out = abs(spectro_noise_out);
db_convolution = 20*log(spectro_convolution);
db_noise_out = 20*log(spectro_noise_out);

figure;
subplot(4,1,1);
    plot(convolution);
    title('Time-domain convoluted');
    xlabel('Filter-taps');
    ylabel('conv');
subplot(4,1,2);
    plot(f_convolution,mean(spectro_convolution,2));
    title('Frequency-domain conv');
    xlabel('f (Hz)');
    ylabel('conv (dB)');
subplot(4,1,3);
    plot(out);
    title('Time-domain recorded');
    xlabel('Filter-taps');
    ylabel('noise_out');
subplot(4,1,4);
    plot(f_noise_out,mean(spectro_noise_out,2));
    title('Frequency-domain noise_out');
    xlabel('f (Hz)');
    ylabel('conv (dB)');

% figure;
% imagesc(f_h, t_h, spectro_h);
% title('Spectrogram of IR2');
% xlabel('f (Hz)');
% ylabel('t (s)');

%Save estimated impulse response to a file
save('IRest.mat','h');

% 2.2.3 Compare the time-domain IR and frequency response obtained with IR2.m
% with what you obtained with IR1.m.  Do they resemble each other?  Why(not)?

%%%% The two spectrums are more or less similar in amplitude. However the
%%%% measure spectrum is a lot more erratic
%%%% The calculated h is shorter

% 2.2.4 Repeat  the  white-noise  experiment  from  exercise  1-2,  and  
% additionally estimate the IR using the same (simin/simout) signals (using 
% your code in IR2.m).  Can you observe a correspondence between the PSD of
% the recorded signalnal and the estimated frequency response?  Why (not)?

%%%%

% 2.2.5 Optional:  Predict what will happen to the IR if you use a stereo 
% speakersetup.  Verify experimentally.

%%%%%% Time domain will be more spread out 

% 2.2.6 Optional: Predict what will happen to the frequency response of the 
% channel  if  you  would  put  your  hand  against  the  loudspeaker.  
% How  will  thischange the shape of the frequency response of the channel, 
% besides the ob-vious higher attenuation?  Now do the experiment and check 
% if you wereright.
%%%%%%%% Peaks combine (why?)