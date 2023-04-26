pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template A(n) {
  signal input a[n];
  signal output b[n];

  for (var i = 0; i < n; i++) {
    b[i] <== a[i];
  }
}

template Array3(n) {
    signal input a[n];
    signal output b[n];

    component a_cmp = A(n);

    for (var i = 0; i < n; i++) {
      a_cmp.a[i] <== a[i];
    }

    for (var i = 0; i < n; i++) {
      a_cmp.b[i] ==> b[i];
    }
}

component main = Array3(5);
