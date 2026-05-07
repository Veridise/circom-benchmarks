pragma circom 2.0.3;

include "../../circuits/hash_to_field.circom";

component main {public [msg]} = HashToField(10, 2);