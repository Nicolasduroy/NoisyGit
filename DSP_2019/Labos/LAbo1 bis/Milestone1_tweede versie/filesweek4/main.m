close all;
clear all;
% Exercise session 4: DMT-OFDM transmission scheme
% Inputvariables
fftSize = 2^10;
Nq = 6;
SNR = 30;
% Channel h
load("IRest.mat")

% Make array with Nq(k) for different qam for different frequencies. 
fresph = fft(h, fftSize/2);
b = zeros(fftSize/2,1);
sigma = 10;
Pn = 20*log10(SNR)*10^-7.5;
for k = 1:fftSize/2
% noise constant beschouwd over hele spectrum
    b(k) = floor(log2(1 +  abs(fresph(k))^2/(sigma*Pn)));
    if b(k) > 6 
        b(k) = 6;
    end
end
% Signaal moet een lengte met een veelvoud van Nqmax*framesize hebben hebben


% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Derived variables
frameSize = fftSize/2-1; % N in functions
z = Nq*frameSize;
M = 2^Nq;

% length = veelvoud van N*Nq voor het behouden van juiste
% matrixverhoudingen en dus het verkrijgen van een geheel aantal symbolen
% en frames.
oldLength = size(bitStream,1);
newLength = z*ceil(oldLength/z);
% newLength = (*ceil(oldLength/);

AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream;

lengthqam = length(AppendedBitStream)/Nq;
P = lengthqam/frameSize; % Amount of (possible) carriers

% QAM modulation 
% (optionnal) Nq volgens b(k)
% qamStream = qam_mod(AppendedBitStream, M);
qamStream = qam_mod_adaptive(AppendedBitStream, b);
% i = 1;
% for k = 1:length(b)
%     qam_mod_element = qam_mod(AppendedBitStream(i:i+b(k)), 2^b(k)); 
%     qam_modulated = [qam_modulated; qam_mod_element]; 
%     i = i + b(k);
% end

% OFDM modulation
load("IRest.mat")
lengthqam = length(AppendedBitStream)/Nq;
P = lengthqam/frameSize;


L = length(h) + 400; % Length of channel-impulseresponse + 100
ofdmStream = ofdm_mod(qamStream, P, lengthqam, L, fftSize);



rxOfdmStream_nonoise = [];
for p = 1:P
    rxOfdmStream_nonoise = [rxOfdmStream_nonoise,fftfilt(h,ofdmStream(:,p))];
end

rxOfdmStream = awgn(rxOfdmStream_nonoise, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStream, P, lengthqam, L, h, fftSize);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
% berTransmission = ber(AppendedBitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
