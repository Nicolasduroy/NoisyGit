clear;
% 2.2.1 How do the transmitted signalu[k], the (unknown) channel IR-vector h,
% and the recorded signaly[k] relate to each other (assuming that noise can
% be  neglected)?   Give  a  matrix  description  of  this  relation  (in  
% the  timedomain).  This yields an overdetermined system of linear equations, 
% where the  vectorhcontains  the  unknown  variables.   The  data  matrix  in  
% this system  of  equations  will  have  a  so-called  Toeplitz  structure  
% to  model  aconvolution.

% 2.2.2 Create  an  m-file IR2.m that  estimates  the  IR h based  on  this 
% matrix description, i.e., by solving the overdetermined system of equations 
% in aleast  squares  sense.   What  dimension  should  you  choose  for h
% (use  the knowledge obtained in exercise 2-1)?  Use white noise as input 
% signalu[k]. Similar to IR1.m, the m-file IR2.m should make a plot of the 
% estimated IRresponse (time-domain), and the (magnitude of the) frequency 
% response.In addition, it should save the IR estimatehas a mat-file IRest.mat

% Initialization
fs = 16000;
dftsize = 2^10;
sig = transpose(wgn(1,2*fs,1));

bandstop = fir1(34, [0.0875 0.375], 'stop');

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