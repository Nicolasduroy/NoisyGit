function ofdmSeq = ofdm_mod(qamSeq, qamNo, cpr)

P = length(qamSeq)/qamNo;

% cfr. figure 2: M-ary QAM OFDM frames and packet
% frame: 0 QAM_i 0 QAM_i*

% Explain the necessity of the `mirror operation' in each frame from a signal processing point of view.
% The mirror operation insures that when the IDFT is applied to the frame,
% the result will be real valued (And hence be realistically transmitable)
packet = reshape(qamSeq, qamNo, P);
packet = [zeros(1,P); packet; zeros(1,P); flipud(conj(packet))];

% Then an IFFT operation is applied to each of the OFDM frames 
fftSize = (qamNo+1)*2;
tPack = ifft(packet,fftSize);
% A cyclic prefix is added (To deal with "channel effect")
cprPacket = [tPack((fftSize-cpr+1):fftSize,:); tPack];
% Resulting frame is parallel-to-serial converted.
ofdmSeq = reshape(cprPacket, P*(fftSize+cpr), 1);

end