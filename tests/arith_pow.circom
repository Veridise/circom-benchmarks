pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template ArithPower() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? in ** 2 : 0;

    out <== inv;
    in * out === 0;
}

component main = ArithPower();
