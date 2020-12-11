function [out_aligned] = alignIO(out,pulse, IRlength, LTx)

startt = ceil(2.3*16000);


% for t = 1:length(outa(startt:3.4*16000))
    

d = finddelay(pulse, abs(out(startt:end)), ceil(0.7*16000));



% d = d+2400
%dd = (d+startt)/16000

out_aligned = out(d+IRlength+startt:d+IRlength+LTx-1+startt);

end

%%% alignement important for finding the trainblock for equalization???

%%% disadvantage because of power normalization and maybe noise problems or
%%% other high points in the signal???