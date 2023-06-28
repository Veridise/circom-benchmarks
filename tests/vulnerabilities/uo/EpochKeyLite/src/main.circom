pragma circom 2.0.0;

include "epochKeyLite.circom";

component main{public [identity_secret, reveal_nonce, attester_id, epoch, nonce, sig_data]} = EpochKeyLite(2);
