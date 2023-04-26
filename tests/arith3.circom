pragma circom 2.0.0;

template Arith3() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a * b * c;
}

component main = Arith3();
