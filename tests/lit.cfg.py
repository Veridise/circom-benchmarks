#!/usr/bin/env python3

import os
import platform

import lit.formats
import lit.util
from lit.llvm import llvm_config
from lit.llvm.subst import FindTool, ToolSubst

assert hasattr(config, "llvm_tools_dir")


config.name = "circom-tests"

config.test_format = lit.formats.ShTest(not llvm_config.use_lit_shell)

config.suffixes = [".circom"]
