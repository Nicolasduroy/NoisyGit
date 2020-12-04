% 2 Create a Matlab function ofdm demod.m that simulates an OFDM-based receiver. In the 
% receiver, a serial-to-parallel conversion is performed, followed by an FFT operation, to
% regenerate the transmitted OFDM frames and QAM symbols.



%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = ofdm_demod(ofdmSeq, fftSize, cpr, qamtrainblock, fs, Lt, Ld)

%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize);

qamvector = [0;qamtrainblock;0;flipud(conj(qamtrainblock))];
fd_datapacket = [];

%% Division into training- and dataframes according to Lt and Ld
p = 1;
while p < P
    

    %% Training
    fresp_est = zeros(fftSize, 1);
    for i = 1:fftSize
        qamvalue = qamvector(i) + zeros(Lt,1);
        fresp_est(i) = qamvalue\transpose(fd_packet(i,p:p+Lt-1));
    end
    

    %% Data
    if Ld == 0
        break
    end
    for j = p+Lt : p+Lt+Ld-1
        fd_datapacket = [fd_datapacket, fd_packet(:,j)./fresp_est];
        fd_packet(:,j) = fd_packet(:,j)./fresp_est; 
        if j == P
            break
        end
    end
    
    p = p + Lt + Ld;
    
end

    if Ld == 0
        demodulatedSequence = 1;
    else
        fd_datapacket = fd_datapacket(2:fftSize/2,:); %%% Get rid of the redundant symbols
        [~,P_data] = size( fd_datapacket );
        demodulatedSequence = reshape(fd_datapacket,qamNo*P_data,1);
    end
end
