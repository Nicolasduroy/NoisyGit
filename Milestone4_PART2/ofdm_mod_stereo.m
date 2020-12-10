function [ofdmStream1, ofdmStream2] = ofdm_mod_stereo(qamStream, qamtrainblock, frameSize, fftSize, cpr, Lt, a, b)
%% setup trainingpackage
qamtrain = [];
for i = 1:Lt
   qamtrain = [qamtrain; qamtrainblock]; 
end
P_train = length(qamtrain)/frameSize;
Trainingpacket = reshape(qamtrain, frameSize, P_train);

%% setup datapackage
P_data = length(qamStream)/frameSize;
Datapacket = reshape(qamStream, frameSize, P_data);

%% Setup whole package
packet = [Trainingpacket, Datapacket];

% Explain the necessity of the `mirror operation' in each frame from a signal processing point of view.
% To ensure the time domain is real_valued
[~,P] = size(packet);
packet = [zeros(1,P); packet; zeros(1,P); flipud(conj(packet))];

%% multiplication with a, b
packetL = packet.*a;
packetR = packet.*b;

% Then an IFFT operation is applied to each of the OFDM frames 
% This is important for the F^-1*H*F step with H diagonal so that the X->Y mapping is orthogonal.
tPackL = ifft(packetL,fftSize); 
tPackR = ifft(packetR,fftSize);
% A cyclic prefix is added to indirectly make a circulant matrix H.
% This has to happen after ifft so that F^-1 * H * F still holds with
% { H = I'^-1 * H_old * I' } and I' is the matrix providing the prefix in the mathematical sense.
cprPacketL = [tPackL((fftSize-cpr+1):fftSize,:); tPackL];
cprPacketR = [tPackR((fftSize-cpr+1):fftSize,:); tPackR];
% Resulting frame is parallel-to-serial converted. This is the way it gets send through.
% Packet after packet
ofdmStream1 = reshape(cprPacketL, P*(fftSize+cpr), 1);
ofdmStream2 = reshape(cprPacketR, P*(fftSize+cpr), 1);

end