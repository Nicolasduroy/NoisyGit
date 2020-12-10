function demodulatedSequence = qam_demod(sequence, M)

%demodInstance = qamdemod('M', M, 'OutputType', 'bit');
%demodulatedSequence = demodulate(demodInstance,qamSequence);
demodulatedSequence  = qamdemod(sequence,M, 'OutputType', 'bit', 'PlotConstellation', false, 'UnitAveragePower', true);

end