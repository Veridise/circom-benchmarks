pragma circom 2.0.0;

template Simple1() {
    signal input a;
    signal output b;
    signal output c;

    b <== a;
    c <== a;
}

component main = Simple1();
