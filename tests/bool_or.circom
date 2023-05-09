pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template BoolNot() {
    signal input a, b;
    signal output out;

    out <-- !(a < b) ? 1 : 0;
}

component main = BoolNot();
