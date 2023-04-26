pragma circom 2.0.0;

// RUN: rm -rf %t && mkdir %t && cargo -C ../circom run -- --llvm -o %t %s && cat %t/simple1_ll/simple1.ll | FileCheck %s
// CHECK: @Simple1_0_build
// CHECK: @Simple1_0_run

template Simple1() {
    signal input a;
    signal output b;

    b <== a;
}

component main = Simple1();