function [t,y] = examplefunc(freq)
%Example function
%First it computes the sampling frequency as 5 times the Nyquist frequency 
%to get a nice plotting result. Then t and y are generated and the plot is made.
%The function also gives a return value. This can be used to call the function 
%in a slightly different way. The t and y variables are then stored in the 
%(global) variables t and y.
freq_sample=10*freq;
t=0:1/freq_sample:0.1;
y=sin(freq*2*pi*t);
plot(t,y);
title('sine wave');
end

