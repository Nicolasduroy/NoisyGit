% Milestone 2a - Corneel T Jonck and Vincent Vanweddingen (groep 5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM OFDM Adaptive Bitloading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
%%%%%%%%%%%%%%%%%%%%
% Setting parameters
%%%%%%%%%%%%%%%%%%%%
Nq = 6;
M = 2^Nq;
cpr = 600;
SNR = 5;
gamma = 10;
fftSize = 2^10;

qamNo = fftSize/2-1;
frameSizeTot = qamNo;

load("IRest.mat");
impRespCh = h;
freqRespCh = fft(impRespCh,fftSize);

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% it can be shown that the optimal QAM choice is M-QAM, where M = 2**b_k 
b_k = zeros(frameSizeTot,1);
for k=1:frameSizeTot
    b_k(k) = log2(1+(abs(freqRespCh(k+1))^2/(gamma*10^(-SNR/10))));
end
% scaling between 0 and max NQ = 6 and flooring
b_k = floor(b_k*6/max(b_k));
b_kTot = sum(b_k);

% Append with zeros to match multiple of b_kTot
oldLength = size(bitStream,1);
newLength = b_kTot*ceil(oldLength/b_kTot);
AppendedBitStream  = zeros(newLength,1);
AppendedBitStream(1:oldLength) = bitStream; 

% create new qamStream, by adaptively filling the stream using b_k
P = ceil(length(bitStream)/b_kTot);
bitPacket = reshape(AppendedBitStream,b_kTot,P);
qamPacket = zeros(frameSizeTot,P);

c = 1;
for i=1:frameSizeTot
    if b_k(i) ~= 0 % skip if zero
        qamPacket(i,:) = qam_mod(2^b_k(i),reshape(bitPacket(c:c+b_k(i)-1,:),b_k(i)*P,1));
        c = c + b_k(i);
    end
end

qamStream = reshape(qamPacket,P*frameSizeTot,1);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,frameSizeTot,cpr);

% Channel
rxOfdmStream = fftfilt(impRespCh,ofdmStream);

% Additive White Gaussian Noise, awgn measures the signal power before adding noise.
rxOfdmStreamAwgn = awgn(rxOfdmStream,SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamAwgn,fftSize,cpr,impRespCh);

% Undoing adaptive bitloading
qamPacket = reshape(rxQamStream,frameSizeTot,P);
bitPacket = zeros(b_kTot,P);

c = 1;
for i=1:frameSizeTot
    if b_k(i) ~= 0
        bitPacket(c:c+b_k(i)-1,:) = reshape(qam_demod(reshape(qamPacket(i,:),P,1),2^b_k(i)),b_k(i),P);
        c = c + b_k(i);
    end
end

rxBitStream = reshape(bitPacket,P*b_kTot,1);

% trim away the appended zeros
rxBitStream = rxBitStream(1:size(bitStream,1),:);

% Compute BER
berTransmission = ber(bitStream,rxBitStream);
disp('BER with adaptive bitloading: ');
disp(berTransmission);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
% Plot images
figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;










