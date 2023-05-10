pragma circom 2.0.0;

// RUN: check-compiles.sh %s %t

template A() {
	signal input a, b, d;
	signal output out;

	out <== (a + b) * d;
}

component main = A();

