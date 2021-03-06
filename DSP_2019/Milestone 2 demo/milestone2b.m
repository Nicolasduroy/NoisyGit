% Milestone 2b - Corneel T Jonck, Emile Clarisse and Nicolas du Roy (group 16)

clear all;
close all;
%%%%%%%%%%%%%%%%%%%%
% Setting parameters
%%%%%%%%%%%%%%%%%%%%
Nq = 6;
M = 2^Nq;
cpr = 600;
SNR = 25;
fftSize = 2^10;
qamNo = fftSize/2-1;
z = Nq*qamNo;
thresh = -110; %% for bitloading, cfr figure 1
thresh2 = -90;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM OFDM without bitloading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
ofdmStream = ofdm_mod(qamStream,qamNo,cpr);

% Set SNR=1 dB and insert a channel with transfer function H(z) = h0 +
% h1z􀀀1 + : : : + hLz􀀀L between the transmitter and receiver, with a user-
% defined channel order L. The channel coefficients can be random numbers,
% or you can choose them yourself.
% L = 150;
% impRespCh = rand(L,1);
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
%[spectro_h, f_h, t_h] = spectrogram(h,2^8,2^7,2^8,16000);
%spectro_h = transpose(mean(20*log(abs(spectro_h)),2));

% Interpolate channel response to length of 511
%t = linspace(1,size(spectro_h,2),size(spectro_h,2)); 
%ti = linspace(1,size(spectro_h,2),511); 
%xi = interp1(t,spectro_h',ti);
%xi = xi';
%spectro_h = xi;

spectro_h = fft(h,fftSize);
spectro_h = transpose(mean(20*log(abs(spectro_h)),2));
spectro_h = spectro_h(1:511);

figure;
plot(spectro_h);
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

% QAM demodulation
rxBitStream = qam_demod(rxQamStream,M);

% Compute BER
berTransmission = ber(AppendedBitStream,rxBitStream);
 
disp('BER without on off bitloading: ');
disp(berTransmission);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); 
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% With On Off bit loading
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

frameSizeTot = qamNo;

% create bit mask sequence
channelSelector = zeros(511, 1);
for i = 1:511
    if spectro_h(i) < thresh || spectro_h(i) > thresh2
        channelSelector(i) = 0;
    else
        channelSelector(i) = 1;
    end
end

qamNo = sum(channelSelector);
z = Nq*qamNo;
% Append with zeros to match multiple of Nq*frameSize
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream; 

% QAM modulation
qamStream = qam_mod(M,AppendedBitStream);

% Send symbols only on those channels that are not too
% much attenuated, send zeros on the others.

lengthCS = length(channelSelector);
lengthStream= length(qamStream);
iterations = lengthStream/qamNo;
n = 1;
tmp = zeros(iterations*lengthCS,1);
for i = 1:iterations-1
  for j = 1:lengthCS
    if channelSelector(j)==1
      tmp(lengthCS*(i-1)+j) = qamStream(n); 
      n=n+1;
    end
  end
end
qamStreamOnOffBitLoaded = tmp;

% OFDM modulation
ofdmStream = ofdm_mod(qamStreamOnOffBitLoaded,frameSizeTot,cpr);

% Channel
rxOfdmStream = fftfilt(impRespCh,ofdmStream);

% Additive White Gaussian Noise, awgn measures the signal power before adding noise.
rxOfdmStreamAwgn = awgn(rxOfdmStream,SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamAwgn,fftSize,cpr,impRespCh);

 
% Undoing the on off bit loading
rxQamStreamOnOffBitloadingUndone = zeros(iterations*qamNo,1);
n=1;
for i = 1:iterations-1
  for j=1:lengthCS
    if channelSelector(j)==1
      rxQamStreamOnOffBitloadingUndone(n)= rxQamStream(lengthCS*(i-1)+j);
      n=n+1;
    end
  end
end
    
% QAM demodulation
rxBitStream = qam_demod(rxQamStreamOnOffBitloadingUndone,M);

% trim away the appended zeros
rxBitStream = rxBitStream(1:size(bitStream,1),:);

% Compute BER
berTransmission = ber(bitStream,rxBitStream);
disp('BER with on off bitloading: ');
disp(berTransmission);

% Compute bit transmission rate
% Per period Tu (= 1/delta_f), Sum(b(k)) or Nq*N bits get sent through
% Noinfo during cyclic prefix 
P = length(qamStreamOnOffBitLoaded)/qamNo; % amount of carriers
f_max = 8000; % function of fftSize
delta_f = f_max/P;
Time_cpr = (cpr/qamNo)/delta_f; 
Tu = 1/delta_f;
bitrate = Nq*qamNo/(Tu+Time_cpr);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image');
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); 

