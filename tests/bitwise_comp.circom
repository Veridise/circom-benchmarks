pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template BitwiseComplement() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- ~v;
    check_v <== type*32;
}

component main = BitwiseComplement();
