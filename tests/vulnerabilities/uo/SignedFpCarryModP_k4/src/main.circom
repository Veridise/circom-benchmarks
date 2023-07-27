pragma circom 2.0.0;

include "fp.circom";

component main{public [in]} = SignedFpCarryModP(20, 4, 21, [63, 1, 1, 1]);
