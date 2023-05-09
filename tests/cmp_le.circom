pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template CmpLE(n) {
    signal input a[n];
    signal output b[n];

    for (var i = 0; i <= n-1; i++) {
      b[i] <== a[i];
    }
}

component main = CmpLE(5);
