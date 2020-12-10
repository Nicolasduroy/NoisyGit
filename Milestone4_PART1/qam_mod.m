
% Create a Matlab function qam mod.m that modulates a sequence of bits into M-ary QAM format
function modulatedSequence = qam_mod(M, sequence)

%h = qammod('M', M, 'InputType', 'bit');
%modulatedSequence = modulate(h,sequence);

modulatedSequence  = qammod(sequence,M, 'InputType', 'bit', 'PlotConstellation', false, 'UnitAveragePower', true);
end