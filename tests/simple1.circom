pragma circom 2.0.0;

template Simple1() {
    signal input a;
    signal output b;

    b <== a;
}

component main = Simple1();