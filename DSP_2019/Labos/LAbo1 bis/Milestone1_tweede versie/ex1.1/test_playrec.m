clear;

% Create a sinewave of 2 seconds, f = 1500Hz, fs = 16000
fs = 16000;
T = 2;
t = 0: 1/fs :T;
f = 400;
sinewave = [sin(2*pi*f*t)];

% Setting simulink variables, simulate, record in out and play recorded
% signal using the correct fs
[simin, nbsecs, fs] = initparams(transpose(sinewave),fs);
sim('recplay');
out=simout.signals.values;
soundsc(out,fs);
