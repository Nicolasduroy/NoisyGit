function ofdmSeq = old_ofdm_mod(qamSeq, frameSize, cpr)


% P = amount of frequency bins.
P = length(qamSeq)/frameSize;

% Explain the necessity of the `mirror operation' in each frame from a signal processing point of view.
% We willen enkel positieve frequenties
packet = reshape(qamSeq, frameSize, P);
packet = [zeros(1,P); packet; zeros(1,P); flipud(conj(packet))];

% ifft zorgt ervoor dat de waarden van de kolommen zijn aangepast naar de 
% draagfrequentie. De frequentie hangt niet af van positie in datastring.
% Hierna wordt de parallel-structuur geserialiseerd.

% ifft
fftSize = (frameSize + 1)*2;
tPack = ifft(packet,fftSize);

% cyclic prefix adding
prefPack = [tPack((fftSize-cpr+1):fftSize,:); tPack];

% serialization
ofdmSeq = reshape(prefPack, P*(fftSize+cpr), 1);
end