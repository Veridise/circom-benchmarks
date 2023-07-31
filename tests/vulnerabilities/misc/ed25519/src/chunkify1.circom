pragma circom 2.0.0;

include "../../../../libs/zksolid-libs/ed25519-099d19c-fixed/chunkify.circom";

component main = Chunkify(256, 51);