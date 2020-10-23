function errorRate = ber(transmittedSeq, receivedSeq)

berrors = biterr(transmittedSeq, receivedSeq);
errorRate = berrors/length(transmittedSeq);

end