#!/bin/sh

# Tries to compile a file and it should not succeed

source_file=$1
tmp_output=$2

rm -rf "$tmp_output" && mkdir "$tmp_output"
if ! cargo -C ../circom run -- --llvm -o "$tmp_output" "$source_file"; then
  exit 0
else
  exit 1
fi