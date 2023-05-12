pragma circom 2.0.0;

template ArrayXOR(n) {
    signal input a[n];
    signal input b[n];
    signal output out[n];
    
    // DUMMY BEGINS
    component dummy_comp = Multiplier();
    dummy_comp.inp <-- a[0];
    signal dummy;
    dummy <-- dummy_comp.out - 2*a[0];
    // DUMMY ENDS

    for (var i = 0; i < n; i++) {
        out[i] <-- a[i] ^ b[i];
    }
}

// DUMMY BEGINS
template Multiplier() {
    signal input  inp;
    signal output out;
    // Ignore the computation here.
    out <-- 2*inp;
}
// DUMMY ENDS


//component main = ArrayXOR(4);
