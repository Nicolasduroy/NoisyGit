% Exercise session 4: DMT-OFDM transmission scheme

clear all;
close all;

Nq = 6;
M = 2^Nq;
cpr = 600;
SNR = 25;
fftSize = 2^10;
frameSize = fftSize/2-1;
z=Nq*frameSize;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Append with zeros to match multiple of NQ
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream; 

% QAM modulation
qamStream = qam_mod(M,AppendedBitStream);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,frameSize,cpr);

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

% QAM demodulation
rxBitStream = qam_demod(rxQamStream,M);

% Compute BER
 berTransmission = ber(AppendedBitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
