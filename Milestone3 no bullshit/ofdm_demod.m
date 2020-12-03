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
    

    % Training
    fresp_est = zeros(fftSize, 1);
    for i = 1:fftSize
        qamvalue = qamvector(i) + zeros(Lt,1);
        fresp_est(i) = qamvalue\transpose(fd_packet(i,p:p+Lt-1));
    end
    
    h_est = ifft(fresp_est, fftSize);
    t_est = linspace(0,1024,1024);
    f = linspace(0, fs/2, fftSize);
    
    figure;
    subplot(2,1,1);
        plot(t_est, h_est);
        title('Estimate of impulseresponse: time-domain');
        xlabel('filtertaps');
        ylabel('Imulse Response amplitude');
    subplot(2,1,2);
        plot(f, fresp_est);
        title('Estimate of impulseresponse: frequency-domain');
        xlabel('frequency');
        ylabel('Imulse Response amplitude');
    
    %Data
    for j = p+Lt : p+Lt+Ld-1
        fd_datapacket = [fd_datapacket, fd_packet(:,j)./fresp_est];
        fd_packet(:,j) = fd_packet(:,j)./fresp_est; 
    end
    
    p = p + Lt + Ld;
    
end


fd_datapacket = fd_datapacket(2:fftSize/2,:); %%% Get rid of the redundant symbols
[~,P_data] = size( fd_datapacket );
demodulatedSequence = reshape(fd_datapacket,qamNo*P_data,1);

end
