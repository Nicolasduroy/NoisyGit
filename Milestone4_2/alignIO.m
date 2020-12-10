function [out_aligned] = alignIO(out,pulse, IRlength, LTx)

d = finddelay(pulse, out, 40000);

out_aligned = out(d+IRlength-20:d+IRlength-20+LTx-1);

end

%%% alignement important for finding the trainblock for equalization???

%%% disadvantage because of power normalization and maybe noise problems or
%%% other high points in the signal???