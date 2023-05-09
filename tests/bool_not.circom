pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template BoolOr() {
    signal input a, b;
    signal output out;

    out <-- (a > 0 || b > 0) ? 1 : 0;
}

component main = BoolOr();
