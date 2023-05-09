pragma circom 2.0.0;

// RUN: test_compilation.py --src %s --tmp %t --out reports/$(basename %s).json

template Simple1() {
    signal input a;
    signal output b;

    b <== a;
}

component main = Simple1();