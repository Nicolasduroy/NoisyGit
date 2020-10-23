
% Define 3 variables that can be set by the user: sig,fs and dftsize.  
% Do not define analyzerec as a function, i.e., these input parameters must
% be hardcoded  in  the  m-file.

dftsize = 2^11;
fs = 16000;

% Create a sine wave for 2 seconds
T = 2;
t = 0: 1/fs: T;
f = 400;
dc = 1.25;
% sig = 0.5*sin(2*pi*f*t) + dc;
% sig = sin(2*pi*50*t) + sin(2*pi*100*t) + sin(2*pi*200*t) + sin(2*pi*500*t) + sin(2*pi*1000*t) + sin(2*pi*2000*t) + sin(2*pi*4000*t) + sin(2*pi*6000*t);
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

%Plot spectrograms
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

% Calculate the PSD by averaging multiple periodogram spectrum estimates, 
% all with a DFT size equal to dftsize. This way of estimating the PSD is 
% referred to as Bartlett's method or Welch's method. What is the difference
% between these two methods, and how does their result differ from the actual PSD?

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
 
    
 % 1.2.2 Set sig in analyzerec.m to a sine sine of 400 Hz, and execute the file. 
 % Take  a  look  at  the  PSD  and  the  spectrogram  of  the transmitted
 % signal(i.e., what is sent to the loudspeakers,not what is recorded).  
 % Is this what you expected?  Are there other frequencies besides the 400 
 % Hz present inthe PSD/spectrogram?  Why (not)?
 %%%%% Geen andere frequenties aanwezig. De toon wordt digitaal aangemaakt
 %%%%% en er zijn geen reflecties binnenin of Niet LTI-effecten.
 
 
 % 1.2.3 What is the influence of the DFT size?  Try to answer first and then 
 % verify experimentally.
 %%%%%%%%%%% (frequentie-)Resolutie gaat omlaag
 
 
 % 1.2.4 Now  compare  the  spectrogram/PSD  of  the  transmitted  signal  
 % and  the recorded signal.  Is this what you expected?
 %%%%%%% Er zijn frequenties en ruis bijgekomen. Deze zijn te denken aan de
 %%%%%%% omgeving, eigenschappen speaker en microfoon en weerkaatsingen
 %%%%%%% van het het geluid in de ruimte.
 
 % 1.2.5 Repeat the previous experiment, but add a DC component to the sinewave. 
 % What do you observe now? Is this what you expected?
 %%%%%% Bij de input is er een dc-component in de PSD maar bij het
 %%%%%% opgenomen signaal is deze component verdwenen. Een speaker die op
 %%%%%% een constante hoogte staat ingedrukt kan deze "beweging" niet continu
 %%%%%% doorgeven zodat de microfoon deze "ingedrukte" beweging in
 %%%%%% overneemt.
 
 
 % 1.2.6 Did  you  properly  scale  the  signal  in  the  previous  
 % experiment  to  avoidclipping (i.e., Matlab expects audio samples to be 
 % in the interval [?1,1])? If you did:  nice!  What is the influence of 
 % clipping in the spectrum?  Try it out.  Is this harmful for the acoustic modem?
 %%%%%%%% Geluidsignaal wordt stiller bij clippen, hoewel dit vooral bij de lage frequenties speelt.
 %%%%%%%% korte puls in begin en einde van het signaal.
 
 
 % 1.2.7 Add  a  line  of  code  in initparams.m that  automatically  scales  
 % the  inputsignal  to  the  interval  [?1,1]  to  avoid  clipping.   Note  
 % that  clipping  can still occur due to non-linearities in the speakers/
 % microphone, in particular when operating at a high volume.  Hence, be careful!
 
 % 1.2.8 Define sig in analyzerec.m as a signal containing a sum of sines of 
 % 100,200, 500, 1000, 1500, 2000, 4000 and 6000 Hz (with equal amplitude), 
 % and execute the file.  Take a look at the PSD and the spectrogram.  Can 
 % you locate the original frequencies in the spectrogram?  Is there a 
 % difference between the PSD/spectrogram of the transmitted and the 
 % recorded signal? Can you explain this?
 %%%%%%% Het opgenomen signaal heeft dezelfe pieken als het inputsignaal.
 %%%%%%% Echter zijn op lagere sterkte heel wat frequenties bijgekomen met
 %%%%%%% een regelmatig patroon (door weerkaatsingen?).Daarnaast is er ook
 %%%%%%% nog extra ruis op het signaal.
 
 
 % 1.2.9 Define sig in analyzerec.m as a white noise signal, and execute the 
 % file. What relevant information for the acoustic modem can be found in 
 % the spectrogram of the recorded signal?  This white noise experiment is 
 % important for later sessions.
 %%%%%%%%%%%% Je ziet duidelijk welke frequenties beter en slechter worden
 %%%%%%%%%%%% doorgegeven.
 
 
 % 1.2.10 In  the  previous  white  noise  experiment,  does  the  spectrogram 
 % of  the recorded white-noise signal change significantly in time?  Why is 
 % this question relevant for the acoustic modem?
 %%%%%%%%%% Interressant voor het bepalen van de bandbreedte?
 
 % 1.2.11 Redo the white noise experiment, but move the microphone around 
 % while recording.  What do you observe now in the spectrogram?
 %%%%%%%%%% (Heen-en-weer-beweging) Golf in het tijdspectrum (luider
 %%%%%%%%%% zachter) en veel minder duidelijke (mss placebo) golf in het
 %%%%%%%%%% freqspec.
 
 
