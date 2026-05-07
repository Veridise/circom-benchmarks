pragma circom 2.0.3;

include "../../circuits/ssz.circom";

component main {public [in]} = SSZArray(128, 2);
