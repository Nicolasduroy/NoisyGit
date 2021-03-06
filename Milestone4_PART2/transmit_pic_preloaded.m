clear all;
close all;

%% Init base-parameters
fs = 16000;
Nq = 4;
M = 2^Nq;
fftSize = 2^10; %% DFTsize N
frameSize = fftSize/2-1;
trainblock_length = frameSize*Nq;
z = Nq*frameSize;

%% Channel_1 init
load("IRest1.mat");
%IR1 = rand([250, 1]) + 0.1;
impRespCh1 = IR1;
t = linspace(0,length(impRespCh1),length(impRespCh1));
fresp_h1 = fft(impRespCh1, fftSize);
f = linspace(0, fs/2, fftSize);
figure;
subplot(2,1,1);
    plot(t, impRespCh1);
    title('impulseresponse1 time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h1);
    title('impulseresponse1 frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

%% Channel_2 init
load("IRest2.mat");
%IR1 = rand([250, 1]) + 0.1;
impRespCh2 = IR1;
t = linspace(0,length(impRespCh1),length(impRespCh1));
fresp_h2 = fft(impRespCh2, fftSize);
f = linspace(0, fs/2, fftSize);
figure;
subplot(2,1,1);
    plot(t, impRespCh2);
    title('impulseresponse2 time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h2);
    title('impulseresponse2 frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

%% Create a, b
[a, b, H12] = fixed_transmitter_side_beamformer(fresp_h1, fresp_h2);

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
Lt = 100;
[Tx1,Tx2] = ofdm_mod_stereo(qamStream, qamtrainblock, frameSize, fftSize, cpr, Lt, a, b);

%% Channel sending....    
Rx1 = fftfilt(impRespCh1,Tx1);
Rx2 = fftfilt(impRespCh2,Tx2);
Rx = Rx1+Rx2;


%% Receiving//OFDM-demodulate
channelselector = ones(fftSize/2-1, 1);
[receivedSeq, fresp_est] = visualize_demod(Rx, qamtrainblock, fftSize, cpr, fs, Lt, M, channelselector, qamStream);

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

%% Channel_1 init
load("IRest1.mat");
%IR1 = rand([250, 1]) + 0.1;
impRespCh1 = IR1;
t = linspace(0,length(impRespCh1),length(impRespCh1));
fresp_h1 = fft(impRespCh1, fftSize);
f = linspace(0, fs/2, fftSize);
figure;
subplot(2,1,1);
    plot(t, impRespCh1);
    title('impulseresponse1 time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h1);
    title('impulseresponse1 frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

%% Channel_2 init
load("IRest2.mat");
%IR1 = rand([250, 1]) + 0.1;
impRespCh2 = IR1;
t = linspace(0,length(impRespCh1),length(impRespCh1));
fresp_h2 = fft(impRespCh2, fftSize);
f = linspace(0, fs/2, fftSize);

figure;
subplot(2,1,1);
    plot(t, impRespCh2);
    title('impulseresponse2 time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h2);
    title('impulseresponse2 frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

%% Create a, b
[a, b, H12] = fixed_transmitter_side_beamformer(fresp_h1, fresp_h2);

%% Create trainingblock
trainblock = randi([0 1], trainblock_length, 1);
qamtrainblock = qam_mod(M,trainblock);

%% Prepare for sending
cpr = fftSize/2;
Lt = 50;
[Tx1,Tx2] = ofdm_mod_stereo([], qamtrainblock, frameSize, fftSize, cpr, Lt, a, b);

%% Channel sending....    
Rx1 = fftfilt(impRespCh1,Tx1);
Rx2 = fftfilt(impRespCh2,Tx2);
Rx = Rx1+Rx2;

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
[ofdmStream1,ofdmStream2]  = ofdm_mod_stereo(qamStreamOnOffBitLoaded, qamtrainblock, frameSize, fftSize, cpr, Lt, a, b);

%% Sending...
rxOfdmStream1 = fftfilt(impRespCh1,ofdmStream1);
rxOfdmStream2 = fftfilt(impRespCh2,ofdmStream2);
rxOfdmStream = rxOfdmStream1 + rxOfdmStream2;

%% Receiving
[receivedSeq, fresp_est] = visualize_demod(rxOfdmStream, qamtrainblock, fftSize, cpr, fs, Lt, M, channelSelector,qamStreamOnOffBitLoaded );

%% calculate BER
ber = ber(receivedSeq, StreamBlock);