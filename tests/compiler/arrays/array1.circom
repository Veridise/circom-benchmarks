pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template Array2() {
    signal input a[1];
    signal output b[1];

    b[0] <== a[0];
}

component main = Array2();
