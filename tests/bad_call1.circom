pragma circom 2.0.0;

template A() {
    signal input a;
    signal input b;
    signal output x;

    x <== a + b;
}

template Call1() {
    signal input m;
    signal input n;
    signal output y;

    component a = A();
    a.a <== m;
    // a.b <== n;
    // This circuit should be rejected by the compiler since not all the signals have been allocated
    y <== a.x;
}

component main = Call1();
