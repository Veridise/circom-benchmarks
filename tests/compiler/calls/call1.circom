pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template B() {
    signal input a;
    signal input b;
    signal output x;

    x <== a * b;
}

template Call1() {
    signal input m;
    signal input n;
    signal output y;

    component a = B();
    a.a <== m;
    a.b <== n;
    // Call to A should happen here
    y <== a.x;
}

component main = Call1();
