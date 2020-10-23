function ofdmSeq = ofdm_mod(qamSeq, trainseq, frameSize, cpr, Lt, Ld)


% P = amount of frequency bins.
P = length(qamSeq)/frameSize;

% Explain the necessity of the `mirror operation' in each frame from a signal processing point of view.
% We willen enkel positieve frequenties

%%%%%%%%% trainsequences tussenvoegen%%%%%%%%%%%%%%%%%%%%%%%%%
Ld = 1; %%Aantal dataframes per nieuwe training
packet = reshape(qamSeq, frameSize*ld, P/Ld);
Lt = 1; %%Aantal trainingframes per training
Training = [];
for i = 1:Lt
    Training = [Training;trainseq];
end
[~,nn] = size(packet);
pckt = [];
for i = 1:nn
    pckt(:,i) = [packet(:,i);Training];
end
pckt = pckt(:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Alles naar behoren zetten%%%%%%%%%%%%%%%
packet = reshape(qamSeq, framesize, P);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%DC-componenten toevoegen enzoo%%%%%%%%%%%%%%%%%%%%
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