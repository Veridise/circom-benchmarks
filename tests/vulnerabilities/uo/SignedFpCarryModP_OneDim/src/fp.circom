pragma circom 2.0.3;

// include "../libs/circom-pairing/circuits/bitify.circom";

// solve for in = p * X + out
// assume in has registers in (-2^overflow, 2^overflow) 
// X has registers lying in [-2^n, 2^n) 
// X has at most Ceil( overflow / n ) registers 

// out has registers in [0, 2^n) but don't constrain out < p
template SignedFpCarryModP_OneDim(n, overflow, p){
    signal input in[1]; 
    var m = (overflow + n - 1) \ n; 
    signal output X[m];
    signal output out[1];

    assert( overflow < 251 );

    var Xvar[2][50] = get_signed_Fp_carry_witness(n, 1, m, in, p); // X, out
    component X_range_checks[m];
    component range_checks[1]; 
    //component lt = BigLessThan(n, k); 

    out[0] <-- Xvar[1][0];
    range_checks[0] = Num2Bits(n); 
    range_checks[0].in <== out[0];
            
    for(var i=0; i<m; i++){
        X[i] <-- Xvar[0][i];
        X_range_checks[i] = Num2Bits(n+1);
        X_range_checks[i].in <== X[i] + (1<<n); // X[i] should be between [-2^n, 2^n)
    }
    
    component mod_check = CheckCarryModP(n, m, overflow, p);
    mod_check.in[0] <== in[0];
    mod_check.Y[0] <== out[0];
    
    for(var i=0; i<m; i++){
        mod_check.X[i] <== X[i];
    }
}

// a[k] registers can overflow
//  assume actual value of a < 2^{n*(k+m)} 
// p[k] registers in [0, 2^n)
// out[2][k] solving
//      a = p * out[0] + out[1] with out[1] in [0,p) 
// out[0] has m registers in range [-2^n, 2^n)
// out[1] has k registers in range [0, 2^n)
function get_signed_Fp_carry_witness(n, k, m, a, p){
    var out[2][50];
    var a_short[51] = signed_long_to_short(n, k, a); 

    /* // commenting out to improve speed
    // let me make sure everything is in <= k+m registers
    for(var j=k+m; j<50; j++)
        assert( a_short[j] == 0 );
    */

    if(a_short[50] == 0){
        out = long_div2(n, k, m, a_short, p);    
    }else{
        var a_pos[50];
        for(var i=0; i<k+m; i++) 
            a_pos[i] = -a_short[i];

        var X[2][50] = long_div2(n, k, m, a_pos, p);
        // what if X[1] is 0? 
        var Y_is_zero = 1;
        for(var i=0; i<k; i++){
            if(X[1][i] != 0)
                Y_is_zero = 0;
        }
        if( Y_is_zero == 1 ){
            out[1] = X[1];
        }else{
            out[1] = long_sub(n, k, p, X[1]); 
            
            X[0][0]++;
            if(X[0][0] >= (1<<n)){
                for(var i=0; i<m-1; i++){
                    var carry = X[0][i] \ (1<<n); 
                    X[0][i+1] += carry;
                    X[0][i] -= carry * (1<<n);
                }
                assert( X[0][m-1] < (1<<n) ); 
            }
        }
        for(var i=0; i<m; i++)
            out[0][i] = -X[0][i]; 
    }

    return out;
}

// a = a0 + a1 * X + ... + a[k-1] * X^{k-1} with X = 2^n
//  a_i can be "negative" assume a_i in (-2^251, 2^251) 
// output is the value of a with a_i all of the same sign 
// out[50] = 0 if positive, 1 if negative
function signed_long_to_short(n, k, a){
    var out[51];
    var MAXL = 50;
    var temp[51];

    // is a positive?
    for(var i=0; i<k; i++) temp[i] = a[i];
    for(var i=k; i<=MAXL; i++) temp[i] = 0;

    var X = (1<<n); 
    for(var i=0; i<MAXL; i++){
        if(temp[i] >= 0){ // circom automatically takes care of signs in comparator 
            out[i] = temp[i] % X;
            temp[i+1] += temp[i] \ X;
        }else{
            var borrow = (-temp[i] + X - 1 ) \ X; 
            out[i] = temp[i] + borrow * X;
            temp[i+1] -= borrow;
        }
    }
    if(temp[MAXL] >= 0){
        assert(temp[MAXL]==0); // otherwise not enough registers!
        out[MAXL] = 0;
        return out;
    }
    
    // must be negative then, reset
    for(var i=0; i<k; i++) temp[i] = a[i];
    for(var i=k; i<=MAXL; i++) temp[i] = 0;

    for(var i=0; i<MAXL; i++){
        if(temp[i] < 0){
            var carry = (-temp[i]) \ X; 
            out[i] = temp[i] + carry * X;
            temp[i+1] -= carry;
        }else{
            var borrow = (temp[i] + X - 1 ) \ X; 
            out[i] = temp[i] - borrow * X;
            temp[i+1] += borrow;
        }
    }
    assert( temp[MAXL] == 0 ); 
    out[MAXL] = 1;
    return out;
}

// n bits per register
// a has k + m registers
// b has k registers
// out[0] has length m + 1 -- quotient
// out[1] has length k -- remainder
// implements algorithm of https://people.eecs.berkeley.edu/~fateman/282/F%20Wright%20notes/week4.pdf
// b[k-1] must be nonzero!
function long_div2(n, k, m, a, b){
    var out[2][50];
    // assume k+m < 50
    var remainder[50];
    for (var i = 0; i < m + k; i++) {
        remainder[i] = a[i];
    }

    var dividend[50];
    for (var i = m; i >= 0; i--) {
        if (i == m) {
            dividend[k] = 0;
            for (var j = k - 1; j >= 0; j--) {
                dividend[j] = remainder[j + m];
            }
        } else {
            for (var j = k; j >= 0; j--) {
                dividend[j] = remainder[j + i];
            }
        }
        out[0][i] = short_div(n, k, dividend, b);
        var mult_shift[50] = long_scalar_mult(n, k, out[0][i], b);
        var subtrahend[50];
        for (var j = 0; j < m + k; j++) {
            subtrahend[j] = 0;
        }
        for (var j = 0; j <= k; j++) {
            if (i + j < m + k) {
               subtrahend[i + j] = mult_shift[j];
            }
        }
        remainder = long_sub(n, m + k, remainder, subtrahend);
    }
    for (var i = 0; i < k; i++) {
        out[1][i] = remainder[i];
    }
    out[1][k] = 0;
    return out;
}

// a is a n-bit scalar
// b has k registers
function long_scalar_mult(n, k, a, b) {
    var out[50];
    for (var i = 0; i < 50; i++) {
        out[i] = 0;
    }
    for (var i = 0; i < k; i++) {
        var temp = out[i] + (a * b[i]);
        out[i] = temp % (1 << n);
        out[i + 1] = out[i + 1] + temp \ (1 << n);
    }
    return out;
}


// n bits per register
// a has k registers
// b has k registers
// a >= b
function long_sub(n, k, a, b) {
    var diff[50];
    var borrow[50];
    for (var i = 0; i < k; i++) {
        if (i == 0) {
           if (a[i] >= b[i]) {
               diff[i] = a[i] - b[i];
               borrow[i] = 0;
            } else {
               diff[i] = a[i] - b[i] + (1 << n);
               borrow[i] = 1;
            }
        } else {
            if (a[i] >= b[i] + borrow[i - 1]) {
               diff[i] = a[i] - b[i] - borrow[i - 1];
               borrow[i] = 0;
            } else {
               diff[i] = (1 << n) + a[i] - b[i] - borrow[i - 1];
               borrow[i] = 1;
            }
        }
    }
    return diff;
}


// n bits per register
// a has k + 1 registers
// b has k registers
// assumes leading digit of b is non-zero
// 0 <= a < b * 2^n
function short_div(n, k, a, b) {
    var scale = (1 << n) \ (1 + b[k - 1]);
    // k + 2 registers now
    var norm_a[50] = long_scalar_mult(n, k + 1, scale, a);
    // k + 1 registers now
    var norm_b[50] = long_scalar_mult(n, k, scale, b);
    
    var ret;
    if (norm_b[k] != 0) {
	ret = short_div_norm(n, k + 1, norm_a, norm_b);
    } else {
	ret = short_div_norm(n, k, norm_a, norm_b);
    }
    return ret;
}

// n bits per register
// a has k + 1 registers
// b has k registers
// assumes leading digit of b is at least 2^(n - 1)
// 0 <= a < (2**n) * b
function short_div_norm(n, k, a, b) {
   var qhat = (a[k] * (1 << n) + a[k - 1]) \ b[k - 1];
   if (qhat > (1 << n) - 1) {
      qhat = (1 << n) - 1;
   }

   var mult[50] = long_scalar_mult(n, k, qhat, b);
   if (long_gt(n, k + 1, mult, a) == 1) {
      mult = long_sub(n, k + 1, mult, b);
      if (long_gt(n, k + 1, mult, a) == 1) {
         return qhat - 2;
      } else {
         return qhat - 1;
      }
   } else {
       return qhat;
   }
}


/* Taken from circom-ecdsa
Input: 
    - in = in[0] + in[1] * X + ... + in[k-1] * X^{k-1} as signed overflow representation
    - Assume each in[i] is in range (-2^{m-1}, 2^{m-1})
Implements:
    - constrain that in[] evaluated at X = 2^n as a big integer equals zero
*/
template CheckCarryToZero(n, m, k) {
    assert(k >= 2);
    
    var EPSILON = 1; // see below for why 1 is ok
    
    signal input in[k];
    
    signal carry[k];
    component carryRangeChecks[k];
    for (var i = 0; i < k-1; i++){
        carryRangeChecks[i] = Num2Bits(m + EPSILON - n); 
        if( i == 0 ){
            carry[i] <-- in[i] / (1<<n);
            in[i] === carry[i] * (1<<n);
        }
        else{
            carry[i] <-- (in[i]+carry[i-1]) / (1<<n);
            in[i] + carry[i-1] === carry[i] * (1<<n);
        }
        // checking carry is in the range of -2^(m-n-1+eps), 2^(m-n-1+eps)
        carryRangeChecks[i].in <== carry[i] + ( 1<< (m + EPSILON - n - 1));
        // carry[i] is bounded by 2^{m-1} * (2^{-n} + 2^{-2n} + ... ) = 2^{m-n-1} * ( 1/ (1-2^{-n})) < 2^{m-n} by geometric series 
    }
    
    in[k-1] + carry[k-2] === 0;
}


/*
same as BigMultShortLong except a has degree ka - 1, b has degree kb - 1
    - If a[i], b[j] have absolute value < B, then out[i] has absolute value < min(ka, kb) * B^2 
*/
template BigMultShortLongUnequal(n, ka, kb, m_out) {
    assert(n <= 126);
    signal input a[ka];
    signal input b[kb];
    signal output out[ka + kb - 1];
    
    var prod_val[ka + kb - 1];
    for (var i = 0; i < ka + kb - 1; i++) {
	prod_val[i] = 0;
    }
    for (var i = 0; i < ka; i++) {
	for (var j = 0; j < kb; j++) {
	    prod_val[i + j] = prod_val[i + j] + a[i] * b[j];
	}
    }
    for (var i = 0; i < ka + kb - 1; i++) {
       out[i] <-- prod_val[i];
   }

   var k2 = ka + kb - 1;
   var pow[k2][k2]; 
   for(var i = 0; i<k2; i++)for(var j=0; j<k2; j++)
       pow[i][j] = i ** j; 

   var a_poly[ka + kb - 1];
   var b_poly[ka + kb - 1];
   var out_poly[ka + kb - 1];
   for (var i = 0; i < ka + kb - 1; i++) {
       out_poly[i] = 0;
       a_poly[i] = 0;
       b_poly[i] = 0;
       for (var j = 0; j < ka + kb - 1; j++) {
           out_poly[i] = out_poly[i] + out[j] * pow[i][j];
       }
       for (var j = 0; j < ka; j++) {
           a_poly[i] = a_poly[i] + a[j] * pow[i][j];
       }
       for (var j = 0; j < kb; j++) {
           b_poly[i] = b_poly[i] + b[j] * pow[i][j];
       }
   }
   for (var i = 0; i < ka + kb - 1; i++) {
      out_poly[i] === a_poly[i] * b_poly[i];
   }
}

// 1 if true, 0 if false
function long_gt(n, k, a, b) {
    for (var i = k - 1; i >= 0; i--) {
        if (a[i] > b[i]) {
            return 1;
        }
        if (a[i] < b[i]) {
            return 0;
        }
    }
    return 0;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in; 
}


// constrain in = p * X + Y 
// in[i] in (-2^overflow, 2^overflow) 
// assume registers of X have abs value < 2^{overflow - n - log(min(k,m)) - 1} 
// assume overflow - 1 >= n 
template CheckCarryModP(n, m, overflow, p){
    signal input in[1]; 
    signal input X[m];
    signal input Y[1];

    assert( overflow < 251 );
    assert( n <= overflow - 1);
    component pX;
    component carry_check;

    pX = BigMultShortLongUnequal(n, 1, m, overflow); // p has k registers, X has m registers, so output really has k+m-1 registers 
    // overflow register in  (-2^{overflow-1} , 2^{overflow-1})
    pX.a[0] <== p[0];
    pX.b[0] <== X[0];
    pX.b[1] <== X[1];

    // in - p*X - Y has registers in (-2^{overflow+1}, 2^{overflow+1})
    carry_check = CheckCarryToZero(n, overflow+1, m); 
    carry_check.in[0] <== in[0] - pX.out[0] - Y[0];  //out from SignedFp is used here
    for(var i=1; i<m; i++)
        carry_check.in[i] <== -pX.out[i];
}