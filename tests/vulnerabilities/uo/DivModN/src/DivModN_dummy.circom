pragma circom 2.0.3;

template DivModN(n) {
    signal input inp;
    signal output div;
    signal output mod;

    // DUMMY BEGINS
    component dummy_comp = Multiplier();
    dummy_comp.inp <-- inp;
    signal dummy;
    dummy <-- dummy_comp.out - 2*inp;
    // DUMMY ENDS

    // div and mod are unconstrained up to a certain point
    // We are missing the constraint 0 <= mod < n, so we can change div and mod to pass the constraint.

    //Need to fuzz both div and mod to generate a cex
    //For example: 
    // {inp: 15, div: 1, mod: 2} (Initial witness)  works
    // {inp: 15, div: 0, mod: 15} (Mutated witness) also works

    div <-- inp \ n;
    mod <-- inp % n;
    inp === div * n + mod;
}

// DUMMY BEGINS
template Multiplier() {
    signal input  inp;
    signal output out;
    // Ignore the computation here.
    out <-- 2*inp;
}
// DUMMY ENDS

//component main = DivModN(13);
