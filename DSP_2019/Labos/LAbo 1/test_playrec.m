fs  = 16000;
T=1;
t=0:1/fs:T;

f = 400;
sinewave = [sin(2*pi*f*t);sin(2*pi*f*t)];
[simin, nbsecs, fs] = initparams(sinewave,fs);
sim('recplay');
out=simout.signals.values;
soundsc(out,fs);
