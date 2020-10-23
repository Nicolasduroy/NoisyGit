% inputs:
% toplay is a vector that contains the samples of an audio signal
% fs is the sampling frequency at which the playback/recording mustoperate
% outputs:
% simin:  This  is  a  2-column  matrix.   In  case  of  mono  transmission, which we will use during the first six sessions, both columns containthe vectortoplay, with 2 seconds of silence in the beginning, and onesecond of silence at the end
% nbsecs:   The  number  of  seconds  the  playback/recording  must  run(should be at least as long as the signal insimin).
% fs:  This is the samefsthat is given as an input.


function [simin, nbsecs, fs] = initparams(toplay, fs)

% Scale by 1/max to avoid clipping (normalize):
maxToplay = max(toplay);
if maxToplay ~= 0 % check if not equal to zero
  toplay = toplay/maxToplay;
end

column = [zeros(2*fs,1); toplay; zeros(fs,1)];
simin = [column, column];
nbsecs = ceil(size(column, 1)/fs);

