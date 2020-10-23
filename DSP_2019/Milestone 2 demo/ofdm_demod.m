% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.

function demodulatedSequence = ofdm_demod(ofdmSeq, fftSize, cpr,impRespCh)

P = length(ofdmSeq)/(fftSize+cpr);
qamNo = fftSize/2-1;
packet = reshape(ofdmSeq, (fftSize+cpr), P);
% Trim away the cyclic prefix
packet = packet((cpr+1):(fftSize+cpr),:);

fd_packet = fft(packet, fftSize);

fresp = fft(impRespCh,fftSize);

% In the function ofdm demod.m, also scale the components of the FFT output with the inverse 
% of the channel frequency response (this should be given as an extra input variable to the 
% function). Check the BER. Explain what you observe.
for i=1:P
  fd_packet(:,i) = fd_packet(:,i)./fresp;
end

fd_packet = fd_packet(2:fftSize/2,:);

demodulatedSequence = reshape(fd_packet,qamNo*P,1);

end