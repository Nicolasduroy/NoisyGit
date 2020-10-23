% Exercise session 4: DMT-OFDM transmission scheme

clear all;
close all;

Nq = 4;
M = 2^Nq;
cpr = 500;
SNR = 25;
fftSize = 2^10;
frameSizeTot = fftSize/2-1;

% ON-OFF Bit Loading 
channelSelector = [zeros(25,1);ones(400,1);zeros(86,1);];
%channelSelector = [ones(511,1);];
frameSize = sum(channelSelector);
z=Nq*frameSize;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of Nq*frameSize
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream; 

% QAM modulation
qamStream = qam_mod(M,AppendedBitStream);

% Send symbols only on those channels that visually (cfr figure below) are not too
% much attenuated, send zeros on the others.

P = length(qamStream)/frameSize;
qamStreamOnOffBitLoaded = [];
for i=1:P
    tmp = [zeros(25,1);qamStream((i-1)*frameSize+1:(i-1)*frameSize+400);zeros(86,1)];
   % tmp = [qamStream((i-1)*frameSize+1:(i-1)*frameSize+511)];
    qamStreamOnOffBitLoaded = [qamStreamOnOffBitLoaded;tmp];
end

% OFDM modulation
ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded,frameSizeTot,cpr);

% Set SNR=1 dB and insert a channel with transfer function H(z) = h0 +
% h1z􀀀1 + : : : + hLz􀀀L between the transmitter and receiver, with a user-
% defined channel order L. The channel coefficients can be random numbers,
% or you can choose them yourself.
 L = 150;
 impRespCh = rand(L,1);
% impRespCh(1) = 0.2;
% 
load("IRest.mat");
impRespCh = h;


%%%%%%%%%%%%%%%%%%%%%
% For the measured acoustic channel impulse response and a small SNR, you can
% see a lot of errors in the received image. Can you observe any structure in the
% location of the errors and explain your fndings? Inspect the attenuation of your
% channel at different frequencies. Which frequencies have a large attenuation?
%%%%%%%%%%%%%%%%%%%%%

% Looks like the low and especially high frequencies get attenuated the most. 
[spectro_h, f_h, t_h] = spectrogram(h,2^8,2^7,2^8,16000);
spectro_h = transpose(mean(20*log(abs(spectro_h)),2));

figure;
subplot(2,1,1);
    plot(h);
    title('Time-domain IR');
    xlabel('Filter-taps');
    ylabel('Impulse Response');
subplot(2,1,2);
    plot(f_h,spectro_h);
    title('Frequency-domain IR');
    xlabel('f (Hz)');
    ylabel('Impulse Response (dB)');
     

% Channel
rxOfdmStream = fftfilt(impRespCh,ofdmStream);

% Additive White Gaussian Noise, awgn measures the signal power before adding noise.
rxOfdmStreamAwgn = awgn(rxOfdmStream,SNR, 'measured');
%rxOfdmStreamAwgn = rxOfdmStream;

% In the function ofdm demod.m, also scale the components of the FFT output with the inverse 
% of the channel frequency response (this should be given as an extra input variable to the 
% function). Check the BER. Explain what you observe.

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamAwgn,fftSize,cpr,impRespCh);

% Undo the bitloading
rxQamStreamOnOffLoadingUndone = [];
for i=1:P
    tmp = [rxQamStream((i-1)*frameSizeTot+26:(i-1)*frameSizeTot+425);];
    %tmp = [rxQamStream((i-1)*frameSizeTot+1:(i-1)*frameSizeTot+511);];
    rxQamStreamOnOffLoadingUndone = [rxQamStreamOnOffLoadingUndone;tmp;]; 
end

% QAM demodulation
rxBitStream = qam_demod(rxQamStreamOnOffLoadingUndone,M);

% Compute BER
 berTransmission = ber(AppendedBitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);


% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
