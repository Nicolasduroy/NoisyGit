function [out_aligned] = alignIO(out,pulse, IRlength)

correl = xcorr(out,pulse);
[M, I] = max(correl);% Should probably replace with finddelay±±

out_aligned = out(I+IRlength-20:end);

end

%%% alignement important for finding the trainblock for equalization???

%%% disadvantage because of power normalization and maybe noise problems or
%%% other high points in the signal

%{
	function [out_aligned] = alignIO(out,pulse)
    fs = 16000;
    [r,lags] = xcorr(out,pulse);
    [~,I] = max(abs(r));
    delay = lags(I);
    
    out_aligned = out((delay+length(pulse)+(0.5*fs-20)):end);
end
%}