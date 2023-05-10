pragma circom 2.0.0;

// RUN: check-not-compiles.sh %s %t

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

    component a_cmp = A(n+1);

    for (var i = 0; i < n; i++) {
      a_cmp.a[i] <== a[i];
    }

    // We "forgot" to assign a_cmp.a[n+1] and thus this is rejected by the compiler
    for (var i = 0; i < n; i++) {
      a_cmp.b[i] ==> b[i];
    }
}

component main = Array3(5);
