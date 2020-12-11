%%%%% zie slide 29/40
function [demodulatedSequence, fresp_est] = visualize_demod(ofdmSeq, trainblock, fftSize, cpr, fs, Lt, M, channelselector, qamstream)
if ~exist('channelselector','var')
    channelselector = ones(fftSize/2-1, 1);
end
%ofdmSeq = ofdmSeq/max(abs(ofdmSeq));
[Streamblock, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
%% Unchanged part for training/Data
P = length(ofdmSeq)/(fftSize+cpr); % P is amount of columns basically
qamNo = sum(channelselector);
frameSize = fftSize/2-1;

packet = reshape(ofdmSeq, (fftSize+cpr), P);
packet = packet((cpr+1):(fftSize+cpr),:);
fd_packet = fft(packet, fftSize); % Per row 1 frequency

qamvector = [0;trainblock;0;flipud(conj(trainblock))];

IntermediateStream = zeros(length(Streamblock),1);
init_plot = 1;
%% Division into training- and dataframes according to Lt and Ld
%% Division into training- and dataframes according to Lt and Ld
% first do for every freq: DDequalization for trainingframes
% First Lt columns are the trainingframes
Wk = zeros(fftSize, 1);
step = 0.1;
normalph = 0.5;
demodulated = [];
%% Training
Hk = zeros(fftSize, 1);
for r = 1:fftSize
    qamvalue = qamvector(r) + zeros(Lt,1);
    Hk(r) = qamvalue\transpose(fd_packet(r,1:Lt));
    Wk(r) = (1/(Hk(r)'));
end


%% Visualize per Ld frames
Ld = 20;
for loops  =  1 : ceil((P-Lt)/Ld)
    c1 = Lt + 1 + (loops-1)*Ld;
    c2 = Lt + 1 + loops*Ld -1;
    if c2 > P
        c2 = P;
    end
    
    %% Data
    % Asses size of demodSeq before for speedup
    if P > Lt
        for c = c1 : c2 
            for r2 = 2 : fftSize/2 % per tone => per column => 2:fftSize/2 because only necessary symbols needed (pleonasm)
                [X_est, Wk(r2)] = DDequalization(fd_packet(r2,c), step, normalph, Wk(r2), M, qamvector(1), 0);
                demodulated = [demodulated; X_est];
                Hk(r2) = (1/(Wk(r2)'));
            end
        end
        demodulated_sequence_tmp = demodulated;
    else
        demodulated_sequence_tmp = [];
    end
    fresp_est = Hk;
    
    %% Undoing the on off bit loading
    rxQamStreamOnOffBitloadingUndone = zeros((c-Lt)*qamNo, 1);%% This means we use instead of iterations: the P_data (#columns)
    
    n=1;                       
    for it = 1:c-Lt
      for CSj=1:fftSize/2-1%lengthCS %% Length CS is basically = length of information in a frame
        if channelselector(CSj) == 1 
          rxQamStreamOnOffBitloadingUndone(n)= demodulated_sequence_tmp(frameSize*(it-1)+CSj);
          n=n+1;
        end
      end
    end
   
    
    newdata = qam_demod(rxQamStreamOnOffBitloadingUndone, M);
    %% Make plots of impresponse
     
    if init_plot == 1
        figure;
    end
    h_est = ifft(fresp_est, fftSize);
    t_est = linspace(0,fftSize,fftSize);
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
    

    pause(0.002);
end
    demodulatedSequence = newdata;



end
