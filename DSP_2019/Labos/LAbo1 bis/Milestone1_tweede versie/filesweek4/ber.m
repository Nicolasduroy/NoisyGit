function [BER, checkmatrix] = ber(inputsignal, channelled_signal)
    length_signal = length(inputsignal);
    checkmatrix = [inputsignal, channelled_signal];
    BER =1 - sum(inputsignal == channelled_signal)/length_signal;
    
end