#!/bin/sh

# Tries to compile a file and it should succeed

source_file=$1
tmp_output=$2

rm -rf "$tmp_output" && mkdir "$tmp_output"
cargo -C ../circom run -- --llvm -o "$tmp_output" "$source_file"