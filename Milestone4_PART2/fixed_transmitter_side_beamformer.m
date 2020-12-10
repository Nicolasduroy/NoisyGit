

function [a, b, H12] = fixed_transmitter_side_beamformer(H1, H2)


a = zeros(length(H1), 1); %rows, 1 column!!!
b = zeros(length(H2), 1);
H12 = zeros(length(H2), 1);

for i = 1:length(H1)
    H12(i) = sqrt(H1(i)*H1(i)'+H2(i)*H2(i)');
    a(i) = H1(i)'/H12(i);
    b(i) = H2(i)'/H12(i);
end

k = linspace(1,length(H1), length(H1));

figure;
subplot(3,1,1);
    plot(k, H1);
    title('H1');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
subplot(3,1,2);
    plot(k, H2);
    title('H2');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
subplot(3,1,3);
    plot(k, H12);
    title('H12');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');

end