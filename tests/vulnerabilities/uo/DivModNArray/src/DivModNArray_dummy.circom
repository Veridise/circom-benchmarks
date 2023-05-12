pragma circom 2.0.0;

template DivModNArray(n, k) {
    signal input inp[k];
    signal output div[k];
    signal output mod[k];

    // DUMMY BEGINS
    component dummy_comp = Multiplier();
    dummy_comp.inp <-- inp[0];
    signal dummy;
    dummy <-- dummy_comp.out - 2*inp[0];
    // DUMMY ENDS

    // div and mod are unconstrained up to a certain point
    // We are missing the constraint 0 <= mod < n, so we can change div and mod to pass the constraint.

    //Need to fuzz both div and mod to generate a cex
    //For example: 
    // {inp: 15, div: 1, mod: 2} (Initial witness)  works
    // {inp: 15, div: 0, mod: 15} (Mutated witness) also works

    for (var i = 0; i < k; i++) {
        div[i] <-- inp[i] \ n;
        mod[i] <-- inp[i] % n;
        inp[i] === div[i] * n + mod[i];
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


//component main = DivModNArray(13, 2);
