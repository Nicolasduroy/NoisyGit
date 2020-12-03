function [out_aligned] = alignIO(out,pulse, IRlength)

correl = xcorr(out,pulse);
[M, I] = max(correl);

out_aligned = out(I+IRlength-20:end);

end

%%% alignement important for finding the trainblock for equalization???

%%% disadvantage because of power normalization and maybe noise problems or
%%% other high points in the signal???