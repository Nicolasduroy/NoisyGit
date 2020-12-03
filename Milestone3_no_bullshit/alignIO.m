function [out_aligned] = alignIO(out,pulse, IRlength)

d = finddelay(pulse, out);

out_aligned = out(d+IRlength-20:end);

end

%%% alignement important for finding the trainblock for equalization???

%%% disadvantage because of power normalization and maybe noise problems or
%%% other high points in the signal???