clear all;
close all;

fs = 16000;
Nq = 2;
M = 2^Nq;
fftSize = 2^10; %% DFTsize N

%% Trainblock needed of N/2-1 QAM_symbols
%% Nq bits per QAM => trainblock heeft lengte (N/2-1)*Nq

frameSize = fftSize/2-1;

trainblock_length = frameSize*Nq;

[Streamblock, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of Nq
oldLength = size(Streamblock,1);
newLength = trainblock_length*ceil(oldLength/(trainblock_length));

AppendedStreamblock  = zeros(newLength,1);
AppendedStreamblock(1:oldLength) = Streamblock; 
addedzeros = length(AppendedStreamblock) - length(Streamblock);
Streamblock = AppendedStreamblock; %%%%kind of cheating


trainblock = randi([0 1], trainblock_length, 1);

qamtrainblock = qam_mod(M,trainblock);
qamStream = qam_mod(M,Streamblock);

qamtrain = [];
%% Prepare for sending...
cpr = fftSize/2;
Lt = 10;
Ld = 8;
Tx = ofdm_mod(qamStream, qamtrainblock, frameSize, fftSize, cpr, Ld, Lt);
   
%% Sending...
pulse = [0; 0; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength, length(Tx));


%% OFDM-demodulate (QAM inside)
channelSelector = ones(fftSize/2-1, 1);
[receivedSeq, fresp_est] = visualize_demod(Rx, fftSize, cpr, qamtrainblock, fs, Lt, Ld, M, channelSelector);


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
Lt = 10;
Ld = 8;
Tx = ofdm_mod([], qamtrainblock, frameSize, fftSize, cpr, 0, Lt);

%% sending...
pulse = [0; 0; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

Rx = alignIO(out, pulse, IRlength, length(Tx));

%% Receiving
[~, fresp_est] = ofdm_demod(Rx, fftSize, cpr, qamtrainblock, fs, Lt, 0);

image = 0;
f = linspace(0, fs/2, fftSize);
if image == 1
    figure;
    subplot(2,1,1);
        plot(f,fresp_h );
        title('impulseresponse time-domain');
        xlabel('filtertaps');
        ylabel('Imulse Response amplitude');
    subplot(2,1,2);
        plot(f, fresp_est);
        title('impulseresponse frequencydomain');
        xlabel('Frequency');
        ylabel('Imulse Response amplitude');
end

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
for i = 1:iterations                      %%%% precode the zero's in the QAMstream
  for j = 1:lengthCS                        %%%% precode the zero's in the QAMstream
    if channelSelector(j)==1                %%%% precode the zero's in the QAMstream
      tmp(lengthCS*(i-1)+j) = qamStream(n); %%%% precode the zero's in the QAMstream
      n=n+1;                                %%%% precode the zero's in the QAMstream
    end
  end
end
qamStreamOnOffBitLoaded = tmp; %%%Just the new qamstream made here-above

%% OFDM modulation
ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded, qamtrainblock, frameSize, fftSize, cpr, Ld, Lt); %%%%same

%% Sending...
pulse = [0; 1; 1; 1; 0];
IRlength = 511;
[simin, nbsecs, fs] = initparams(ofdmStream, pulse, IRlength, fs);
sim('recplay');
out = simout.signals.values;

rxOfdmStream = alignIO(out, pulse, IRlength, length(ofdmStream));

%% Receiving
[receivedQam, fresp_est] = visualize_demod(rxOfdmStream, fftSize, cpr, qamtrainblock, fs, Lt, Ld, M, channelSelector);

%% QAM-demodulate
%receivedSeq = qam_demod(receivedQam,M);
receivedSeq = receivedQam;
%% calculate BER
ber = ber(receivedSeq, StreamBlock);