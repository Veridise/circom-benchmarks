pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template ArithSubtract() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a - (b - 10);
}

component main = ArithSubtract();
