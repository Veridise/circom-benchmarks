pragma circom 2.0.0;

include "fp.circom";

component main{public [in]} = SignedFpCarryModP(10, 1, 11, [13]);
