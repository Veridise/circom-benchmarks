pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template Simple2(a) {
    signal output b;

    b <== a;
}

component main = Simple2(10);
