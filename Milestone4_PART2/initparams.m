% inputs:
% toplay is a vector that contains the samples of an audio signal
% fs is the sampling frequency at which the playback/recording mustoperate
% outputs:
% simin:  This  is  a  2-column  matrix.   In  case  of  mono  transmission, which we will use during the first six sessions, both columns containthe vectortoplay, with 2 seconds of silence in the beginning, and onesecond of silence at the end
% nbsecs:   The  number  of  seconds  the  playback/recording  must  run(should be at least as long as the signal insimin).
% fs:  This is the samefsthat is given as an input.


function [simin, nbsecs, fs] = initparams(toplay1, toplay2, pulse, IRlength, fs)

% Scale by 1/max to avoid clipping:
maxToplay1 = max(toplay1);
if maxToplay1 ~= 0 % check if not equal to zero
  toplay1 = toplay1/maxToplay1;
end

% Scale by 1/max to avoid clipping:
maxToplay2 = max(toplay2);
if maxToplay2 ~= 0 % check if not equal to zero
  toplay2 = toplay2/maxToplay2;
end

%%% length IR = 511
IR_silence = zeros(IRlength,1);
%%% Pak pulse gebruikt in week 1


column1 = [zeros(2*fs,1);pulse; IR_silence; toplay1; zeros(fs,1)];
column2 = [zeros(2*fs,1);pulse; IR_silence; toplay2; zeros(fs,1)];
simin = [column1, column2];
nbsecs = ceil(size(column1, 1)/fs);

