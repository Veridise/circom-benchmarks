pragma circom 2.0.0;

template Array1(n) {
    signal input a[n];
    signal output b[n];

    for (var i = 0; i < n; i++) {
      b[i] <== a[i];
    }
}

component main = Array1(5);
