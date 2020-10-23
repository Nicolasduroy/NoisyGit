function  [simin,nbsecs,fs]=initparams(toplay,fs)
    simin = [zeros(1,2*fs) toplay(1,:) zeros(1,fs);zeros(1,2*fs) toplay(2,:) zeros(1,fs);]'; %transpon
    nbsecs = size(simin,1)/fs;