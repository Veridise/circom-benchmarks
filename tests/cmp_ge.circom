pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template CmpGE(n) {
    signal input a[n];
    signal output b[n];

    for (var i = n-1; i >= 0; i--) {
      b[i] <== a[i];
    }
}

component main = CmpGE(5);
