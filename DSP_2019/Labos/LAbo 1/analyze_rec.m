%signal
%sampling freq
%freq-spectrum size
     
fs = 16000;
dftsize = 512;
spectrogram(out,hamming(dftsize),floor(dftsize/2),floor(dftsize/4),fs)
%spectrogram(simin(:,1),'yaxis')
sig = out;

%[simin, nbsecs, fs] = initparams(sig, fs);
%sim('recplay')

%out = simout.signals.values;

