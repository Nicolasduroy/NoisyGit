function [BER, checkmatrix] = ber(inputsignal, channelled_signal, length_signal)
    checkmatrix = [inputsignal, channelled_signal];
    BER = sum(inputsignal == channelled_signal)/length_signal;
    
end