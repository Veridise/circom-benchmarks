pragma circom 2.0.0;

template Decoder(w) {
    signal input inp;
    signal output out[w];
    signal output success;
    var lc=0;

    // DUMMY BEGINS
    component dummy_comp = Multiplier();
    dummy_comp.inp <-- inp;
    signal dummy;
    dummy <-- dummy_comp.out - 2*inp;
    // DUMMY ENDS

    //inp == i means out[i] is unconstrained, if inp[i] != i, out[i] must be 0.
    //If we set out[i] to 0 even when inp[i] == i, then the circuit will run fine. 
    for (var i=0; i<w; i++) {
        out[i] <-- (inp == i) ? 1 : 0;
        out[i] * (inp-i) === 0; 
        lc = lc + out[i];
    }

    lc ==> success;
    success * (success -1) === 0;
}

// DUMMY BEGINS
template Multiplier() {
    signal input  inp;
    signal output out;
    // Ignore the computation here.
    out <-- 2*inp;
}
// DUMMY ENDS
