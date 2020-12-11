clear all;
close all;

%% Init base-parameters
fs = 16000;
Nq = 2;
M = 2^Nq;
fftSize = 2^10; %% DFTsize N
frameSize = fftSize/2-1;
trainblock_length = frameSize*Nq;
z = Nq*frameSize;


%% Create streamblock from image
% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of NQ
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z); 
AppendedBitStream  = zeros(newLength,1); 
AppendedBitStream(1:oldLength) = bitStream; 
Streamblock = AppendedBitStream;

%create QAM
qamStream = qam_mod(M,Streamblock);


%% Create trainingblock
trainblock = randi([0 1], trainblock_length, 1);
qamtrainblock = qam_mod(M,trainblock);

%% Prepare for sending
cpr = fftSize/2;
Lt = 50;
Tx = ofdm_mod(qamStream, qamtrainblock, frameSize, fftSize, cpr, Lt);

%% Channel//Sending...
pulse = [0; 0; 0; 10; 0; 0; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength, length(Tx));

%% Receiving//OFDM-demodulate
channelselector = ones(fftSize/2-1, 1);
[receivedSeq, fresp_est] = visualize_demod(Rx, qamtrainblock, fftSize, cpr, fs, Lt, M, channelselector);

%% QAM-demodulate
%receivedSeq = qam_demod(receivedQam,M);

%% Recreate image
imageRx = bitstreamtoimage(receivedSeq, imageSize, bitsPerPixel);

% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

%% calculate BER
ber = ber(receivedSeq, Streamblock);


%% PAUSE %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PAUSE %%%%%%%%%%%%%%%%%%%%%


%% Second part starting...
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
Nq = 2;
M = 2^Nq;
fftSize = 2^10; 
frameSize = fftSize/2-1;
trainblock_length = frameSize*Nq;
BWusage = 70;
frameSize = fftSize/2-1;

%% Create trainingblock
trainblock = randi([0 1], trainblock_length, 1);
qamtrainblock = qam_mod(M,trainblock);

%% Prepare for sending
cpr = fftSize/2;
Lt = 25;
Tx = ofdm_mod([], qamtrainblock, frameSize, fftSize, cpr, Lt);

%% sending...
pulse = [0; 0; 0; 10; 0; 0; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);

sim('recplay');
out = simout.signals.values;
Rx = alignIO(out, pulse, IRlength, length(Tx));

%% Receiving
[~, fresp_est] = ofdm_demod(Rx, fftSize, cpr, Lt, M, qamtrainblock);


%% create bit mask sequence
channelSelector = ones(fftSize/2-1, 1);
channel_del = ceil(length(channelSelector)*(1-BWusage/100));

[~,Ix] = sort(fresp_est(2:fftSize/2));

for j = 1:channel_del
    channelSelector(Ix(j)) = 0;
end

% Adjust qamNo for on/off bitloading
qamNo = sum(channelSelector);
z = Nq*qamNo;

%% Create streamblock from image
% Convert BMP image to bitstream
[StreamBlock, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of Nq*frameSize
oldLength = size(StreamBlock,1);
newLength = z*ceil(oldLength/z);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = StreamBlock; 
addedzeros = length(AppendedBitStream) - length(StreamBlock);
StreamBlock = AppendedBitStream; %%%%kind of cheating
%% QAM modulation
qamStream = qam_mod(M,AppendedBitStream);

% Send symbols only on those channels that are not too
% much attenuated, send zeros on the others.

lengthCS = length(channelSelector);
lengthStream= length(qamStream);
iterations = lengthStream/qamNo; %%% amount of iterations is amount of ofdm_packagess
n = 1;                           %%% REMEMBER qamNo has been adjusted in line 127, so iterations is longer then without on/off bitloading
tmp = zeros(iterations*lengthCS,1);         %%%lenght QAMstream with space for the zero's. 
for i = 1:iterations                        %%%% precode the zero's in the QAMstream
  for j = 1:lengthCS                        %%%% precode the zero's in the QAMstream
    if channelSelector(j)==1                %%%% precode the zero's in the QAMstream
      tmp(lengthCS*(i-1)+j) = qamStream(n); %%%% precode the zero's in the QAMstream
      n=n+1;                                %%%% precode the zero's in the QAMstream
    end
  end
end
qamStreamOnOffBitLoaded = tmp; %%%Just the new qamstream made here-above

%% OFDM modulation
ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded, qamtrainblock, frameSize, fftSize, cpr, Lt); %%%%same

%% Sending...
pulse = [0; 0; 0; 10; 0; 0; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(ofdmStream, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;
rxOfdmStream = alignIO(out, pulse, IRlength, length(ofdmStream));

%% Receiving
[receivedSeq, fresp_est] = visualize_demod(rxOfdmStream, qamtrainblock, fftSize, cpr, fs, Lt, M, channelSelector);

%% calculate BER
ber = ber(receivedSeq, StreamBlock);