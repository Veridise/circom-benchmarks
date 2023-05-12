pragma circom 2.0.0;

template DivModNArray(n, k) {
    signal input inp[k];
    signal output div[k];
    signal output mod[k];

    for (var i = 0; i < k; i++) {
        div[i] <-- inp[i] \ n;
        mod[i] <-- inp[i] % n;
        inp[i] === div[i] * n + mod[i];
    }
}

//component main = DivModNArray(13, 2);
