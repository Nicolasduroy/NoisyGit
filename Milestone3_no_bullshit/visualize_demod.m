%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = visualize_demod(ofdmSeq, fftSize, cpr, qamtrainblock, fs, Lt, Ld, M)
[Streamblock, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize);

qamvector = [0;qamtrainblock;0;flipud(conj(qamtrainblock))];
fd_datapacket = [];

IntermediateStream = zeros(length(Streamblock),1);
init_plot = 1;
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
    for j = p+Lt : p+Lt+Ld-1
        fd_datapacket = [fd_datapacket, fd_packet(:,j)./fresp_est];
        if j == P
            break
        end
    end
    fd_datapacket_tmp = fd_datapacket(2:fftSize/2,:); %%% Get rid of the redundant symbols
    [~,P_data_tmp] = size( fd_datapacket_tmp );
    demodulated_sequence_tmp = reshape(fd_datapacket_tmp,qamNo*P_data_tmp,1);
    newdata = qam_demod(demodulated_sequence_tmp,M);
    %% Make plots of impresponse
     pause(0.2);
    if init_plot == 1
        figure;
    end
    h_est = ifft(fresp_est, fftSize);
    t_est = linspace(0,1024,1024);
    f = linspace(0, fs/2, fftSize);
    subplot(2,2,1);
        im1 = plot(t_est, h_est);
        drawnow
        title('Estimate of impulse response: time-domain');
        xlabel('filtertaps');
        ylabel('Impulse Response amplitude');
    subplot(2,2,3);
        im2 = plot(f, fresp_est);
        drawnow
        title('Estimate of impulse response: frequency-domain');
        xlabel('frequency');
        ylabel('Impulse Response amplitude');
    subplot(2,2,2);     
        colormap(colorMap); 
        image(imageData); 
        axis image;
        title('Transmitted image');
    subplot(2,2,4);
        IntermediateStream(1:length(newdata)) = newdata;
        colormap(colorMap); 
        receivedImage = bitstreamtoimage(IntermediateStream, imageSize, bitsPerPixel);
        im3 = image(receivedImage); 
        axis image;
        title('Recieved image');
    init_plot = 0;
    
    
    p = p + Lt + Ld;
end
    fd_datapacket = fd_datapacket(2:fftSize/2,:); %%% Get rid of the redundant symbols
    [~,P_data] = size( fd_datapacket );
    demodulatedSequence = reshape(fd_datapacket,qamNo*P_data,1);



end
