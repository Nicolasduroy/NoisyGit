clear all;
close all;

%% Init base-parameters
fs = 16000;
Nq = 8;
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
Lt = 500;
Ld = 19;
Tx = ofdm_mod(qamStream, qamtrainblock, frameSize, fftSize, cpr, Lt);
Tx = Tx/max(Tx);

%% Channel//Sending...
load("IRest.mat");
impRespCh = h;
t = linspace(0,500,500);

fresp_h = fft(h, fftSize);
f = linspace(0, fs/2, fftSize);

figure;
subplot(2,1,1);
    plot(t, h);
    title('impulseresponse time-domain');
    xlabel('filtertaps');
    ylabel('Imulse Response amplitude');
subplot(2,1,2);
    plot(f, fresp_h);
    title('impulseresponse frequencydomain');
    xlabel('Frequency');
    ylabel('Imulse Response amplitude');

    
Rx = fftfilt(impRespCh,Tx);
% pulse = [0; 1; 1; 1; 0];
% IRlength = 511;
% [simin, nbsecs, fs] = initparams(Tx, pulse, IRlength, fs);
% sim('recplay');
% out = simout.signals.values;

% Rx = alignIO(out, pulse, IRlength);

%% Receiving//OFDM-demodulate
[receivedQam, fresp_est] = ofdm_demod(Rx, fftSize, cpr, Lt, M, fresp_h);

%% QAM-demodulate
receivedSeq = qam_demod(receivedQam,M);

%% Recreate image
imageRx = bitstreamtoimage(receivedSeq, imageSize, bitsPerPixel);

% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

%% calculate BER
ber = ber(receivedSeq, Streamblock);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% On/Off-bitloading
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% With On Off bit loading  %%%%%%% The more attenuated freqbins wont send any information
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Convert BMP image to bitstream
% [bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
% 
% frameSizeTot = qamNo;
% 
% % create bit mask sequence
% channelSelector = zeros(511, 1); %%% 511 is fftsize/2-1
% for i = 1:511
%     if spectro_h(i) < thresh
%         channelSelector(i) = 0;
%     else
%         channelSelector(i) = 1;
%     end
% end
% 
% qamNo = sum(channelSelector);  %%% Adjust qamNo for on/off bitloading
% z = Nq*qamNo;
% % Append with zeros to match multiple of Nq*frameSize
% oldLength = size(bitStream,1);
% newLength = z*ceil(oldLength/z);
% 
% AppendedBitStream  = zeros(newLength,1);
% AppendedBitStream(1:oldLength) = bitStream; 
% 
% % QAM modulation
% qamStream = qam_mod(M,AppendedBitStream);
% 
% % Send symbols only on those channels that are not too
% % much attenuated, send zeros on the others.
% 
% lengthCS = length(channelSelector);
% lengthStream= length(qamStream);
% iterations = lengthStream/qamNo; %%% amount of iterations is amount of ofdm_packagess
% n = 1;                           %%% REMEMBER qamNo has been adjusted in line 127, so iterations is longer then without on/off bitloading
% tmp = zeros(iterations*lengthCS,1);   %%%lenght QAMstream with space for the zero's. 
% for i = 1:iterations-1                      %%%% precode the zero's in the QAMstream
%   for j = 1:lengthCS                        %%%% precode the zero's in the QAMstream
%     if channelSelector(j)==1                %%%% precode the zero's in the QAMstream
%       tmp(lengthCS*(i-1)+j) = qamStream(n); %%%% precode the zero's in the QAMstream
%       n=n+1;                                %%%% precode the zero's in the QAMstream
%     end
%   end
% end
% qamStreamOnOffBitLoaded = tmp; %%%Just the new qamstream made here-above
% 
% % OFDM modulation
% ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded,frameSizeTot,cpr); %%%%same