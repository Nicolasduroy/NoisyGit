function errorRate = ber(transmittedSeq, receivedSeq)

errorRate = biterr(transmittedSeq, receivedSeq)/length(transmittedSeq);

end