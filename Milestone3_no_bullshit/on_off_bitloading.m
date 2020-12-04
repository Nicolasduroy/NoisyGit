clear all;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% On/Off-bitloading
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% With On Off bit loading  %%%%%%% The more attenuated freqbins wont send any information
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Convert BMP image to bitstream
%% Init base-parameters
fs = 16000;
Nq = 8;
M = 2^Nq;
fftSize = 2^10; 
frameSize = fftSize/2-1;
trainblock_length = frameSize*Nq;
z = Nq*frameSize;
BWusage = 70;

[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

frameSizeTot = fftSize/2-1;

%% Create trainingblock
trainblock = randi([0 1], trainblock_length, 1);
qamtrainblock = qam_mod(M,trainblock);

%% Prepare for sending
cpr = fftSize/2;
Lt = 2;
Ld = 19;
Tx = ofdm_mod([], qamtrainblock, frameSize, fftSize, cpr, 0, Lt);

%% sending...

pulse = [0; 1; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength, length(Tx));
%% Receiving
[~, fresp_est] = ofdm_demod(Rx, fftSize, cpr, qamtrainblock, fs, Lt, 0);

%% create bit mask sequence
channelSelector = ones(fftSize/2-1, 1);
channel_del = ceil(length(channelSelector)*(1-BWusage/100));

[~,Ix] = sort(fresp_est(2:fftSize/2-1));

for k = 1:channel_del
    index = Ix(k);
    channelSelector(index) = 0;
end

% Adjust qamNo for on/off bitloading
qamNo = sum(channelSelector);  
z = Nq*frameSize;

%% Create streamblock from image
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of Nq*frameSize
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream; 

%% QAM modulation
qamStream = qam_mod(M,AppendedBitStream);

% Send symbols only on those channels that are not too
% much attenuated, send zeros on the others.

lengthCS = length(channelSelector);
lengthStream= length(qamStream);
iterations = lengthStream/frameSize; %%% amount of iterations is amount of ofdm_packagess
n = 1;                           %%% REMEMBER qamNo has been adjusted in line 127, so iterations is longer then without on/off bitloading
tmp = zeros(iterations*lengthCS,1);         %%%lenght QAMstream with space for the zero's. 
for i = 1:iterations-1                      %%%% precode the zero's in the QAMstream
  for j = 1:lengthCS                        %%%% precode the zero's in the QAMstream
    if channelSelector(j)==1                %%%% precode the zero's in the QAMstream
      tmp(lengthCS*(i-1)+j) = qamStream(n); %%%% precode the zero's in the QAMstream
      n=n+1;                                %%%% precode the zero's in the QAMstream
    end
  end
end
qamStreamOnOffBitLoaded = tmp; %%%Just the new qamstream made here-above

%% OFDM modulation
ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded, qamtrainblock, frameSizeTot, fftSize, cpr, Lt, Ld); %%%%same

%% Sending...

pulse = [0; 1; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(ofdmStream, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength, length(ofdmStream));
%% Receiving
[receivedQam, fresp_est] = visualize_demod(Rx, fftSize, cpr, qamtrainblock, fs, Lt, Ld, M);

%% QAM-demodulate
receivedSeq = qam_demod(receivedQam,M);

%% calculate BER
ber = ber(receivedSeq, bitStream);
