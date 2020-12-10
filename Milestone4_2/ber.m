function errorRate = ber(transmittedSeq, receivedSeq)

berrors = biterr(transmittedSeq, receivedSeq);
Sum = sum(abs(transmittedSeq - receivedSeq));
errorRate = berrors/length(transmittedSeq)

end