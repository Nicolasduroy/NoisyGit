function [decimal_signal] = bi2de2(binary_signal, N, length_signal)
    decimal_signal = [];
    for i = 1:length_signal/N
        k = (i-1)*N;
        decimal = 0;
        for j = 1:N
            decimal = decimal + binary_signal(k+j)*2^(N-j);
        end
        decimal_signal = [decimal_signal; decimal];
    end
end