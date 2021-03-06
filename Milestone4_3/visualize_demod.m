%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = visualize_demod(ofdmSeq, fftSize, cpr, fs, Lt, M, channelselector)
if ~exist('channelselector','var')
    channelselector = ones(fftSize/2-1, 1);

[Streamblock, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = fftSize/2-1;
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize); % Per row 1 frequency

IntermediateStream = zeros(length(Streamblock),1);
init_plot = 1;
%% Division into training- and dataframes according to Lt and Ld
%% Division into training- and dataframes according to Lt and Ld
% first do for every freq: DDequalization for trainingframes
% First Lt columns are the trainingframes
Wk = zeros(length(fd_packet(1,:)), 1);
step = 0.1;
normalph = 0.5;
Hk_start = 1*((rand(1)-.1) + (rand(1)-.1)*1i);
Wk_start = (1/(Hk_start'))*(1+0.5);

%% Training
for r = 1 : fftSize % per tone => per column => fftSize
    [~, Wk(r)] = DDequalization(fd_packet(r,1:Lt), step, normalph, Wk(r-1)); % Wk(r-1) bc assume fluent spectrum
end

%% Visualize per Ld frames
Ld = 8;
for loops  =  1 : ceil(P/Ld)
    c1 = Lt + 1 + (loops-1)*Ld;
    c2 = Lt + 1 + loops*Ld;
    if c2 > P
        c2 = P;
    end
    
    %% Data
    % Asses size of demodSeq before for speedup
    if P > Lt
        for c = c1 : c2 
            for r2 = 2 : fftSize/2 % per tone => per column => 2:fftSize/2 because only necessary symbols needed (pleonasm)
                [X_est, Wk(r2)] = DDequalization(fd_packet(r2,c), step, normalph, Wk(r2));
                demodulated = [demodulated, X_est];
            end
        end
        demodulatedSequence = demodulated;
    else
        demodulatedSequence = [];
    end
    fresp_est = Wk;
    
    %% Undoing the on off bit loading
    rxQamStreamOnOffBitloadingUndone = zeros(P_data_tmp*qamNo,1);%% This means we use instead of iterations: the P_data (#columns)
    n=1;                       
    for it = 1:P_data_tmp 
      for CSj=1:fftSize/2-1%lengthCS %% Length CS is basically = length of information in a frame
        if channelselector(CSj) == 1 
          rxQamStreamOnOffBitloadingUndone(n)= demodulated_sequence_tmp(frameSize*(it-1)+CSj);
          n=n+1;
        end
      end
    end
   
    
    newdata = qam_demod(demodulated_sequence_tmp, M);
    %% Make plots of impresponse
     
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
        im2 = plot(f, fresp_est.*[1;channelselector;1;flipud(channelselector)]);
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
    pause(0.02);
end
    fd_datapacket = fd_datapacket(2:fftSize/2,:); %%% Get rid of the redundant symbols
    [~,P_data] = size( fd_datapacket );
    demodulatedSequence = reshape(fd_datapacket,qamNo*P_data,1);



end
