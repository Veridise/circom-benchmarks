pragma circom 2.0.0;

// RUN: check-not-compiles.sh %s %t

template Arith3() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a * b * c; // Quadratic constraint. This is rejected by the compiler
}

component main = Arith3();
