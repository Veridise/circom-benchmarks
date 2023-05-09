pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template CmpLT(n) {
    signal input a[n];
    signal output b[n];

    for (var i = 0; i < n; i++) {
      b[i] <== a[i];
    }
}

component main = CmpLT(5);
