import os
import shutil
import subprocess
import tempfile
from pathlib import Path

# test_source_root: The root path where tests are located.
config.test_source_root = Path(__file__).parent

config.llvm_tools_dir = subprocess.check_output(
    ["llvm-config", "--bindir"], text=True
).rstrip()

cargo_path = shutil.which("cargo")
assert cargo_path is not None, "cargo not found on PATH"

config.substitutions.append(("%cargo", f"{cargo_path} -C circom run"))
config.substitutions.append(("%circom-flags", ""))

import lit.llvm

lit.llvm.initialize(lit_config, config)

lit_config.load_config(config, config.test_source_root / "lit.cfg.py")
