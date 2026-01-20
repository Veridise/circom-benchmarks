# Program: circom_to_llzk_eval.py
# Description: This script runs the circom -> llzk frontend
#   on circom-benchmarks and writes a CSV with timing results.
#
# Required Programs:
#   - python3: For running this script
#   - circom: For compiling the benchmarks
#
# Usage: python3 scripts/circom_to_llzk_eval.py [--benchmark_dir PATH] [--timeout SECONDS] [--circom-bin PATH] [--no-concrete/--concrete]
# 
# Example: python3 scripts/circom_to_llzk_eval --timeout 2 --circom-bin ~/veridise/circom/target/bin/circom/ --no-concrete

import argparse
import csv
import os
import re
import subprocess
import time
from typing import List


MAIN_COMPONENT_RE = re.compile(r"^\s*component\s+main\s*=", re.ASCII)

def get_circom_entrypoints(benchmark_dir: str) -> List[str]:
    """Return sorted circom entrypoints that define `component main` under a benchmark dir."""
    circom_entrypoints = []
    for root, _, files in os.walk(benchmark_dir):
        for filename in files:
            if not filename.endswith(".circom"):
                continue
            path = os.path.join(root, filename)
            try:
                with open(path, "r", encoding="utf-8") as handle:
                    for line in handle:
                        if MAIN_COMPONENT_RE.match(line):
                            circom_entrypoints.append(path)
                            break
            except OSError:
                continue
    return sorted(circom_entrypoints)

def run_circom_benchmarks(benchmarks: List[str], benchmark_dir: str, timeout=10, concrete=True, circom_bin="circom"):
    """Run circom->llzk on benchmarks and save timing/error results to a CSV."""
    os.makedirs("llzk-outputs", exist_ok=True)
    results = []
    success_cnt = 0
    error_cnt = 0
    timeout_cnt = 0
    llzk_opt = "concrete" if concrete else "templated"
    for benchmark in benchmarks:
        benchmark_name = os.path.relpath(benchmark, benchmark_dir)
        print(f"Running benchmark: {benchmark_name}")
        start = time.perf_counter()
        try:
            proc = subprocess.run(
                [circom_bin, f"--llzk={llzk_opt}", "-l", os.path.join(benchmark_dir, "tests/libs/"), "-o", "llzk-outputs/", benchmark],
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            elapsed = time.perf_counter() - start
            if proc.returncode == 0:
                print("Ran successfully")
                success_cnt += 1
                results.append((benchmark_name, "success", f"{elapsed:.6f}", ""))
            else:
                print("Errored")
                # currently taking only the first 200 characters or so from stderr 
                # because the full dump can be a lot in some cases
                error_message = proc.stderr.strip()[:200]
                error_cnt += 1
                results.append((benchmark_name, "error", f"{elapsed:.6f}", error_message))
        except subprocess.TimeoutExpired:
            elapsed = time.perf_counter() - start
            timeout_cnt += 1
            print("Timed out")
            results.append((benchmark_name, "timeout", f"{elapsed:.6f}", "timeout"))
    output_path = f"circom_benchmarks_results_{llzk_opt}.csv"
    with open(output_path, "w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["Benchmark", "Result", "Time Seconds", "Error Message"])
        writer.writerows(results)
    print(f"success: {success_cnt}, errored: {error_cnt}, timeout: {timeout_cnt}")
    return output_path

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Run circom benchmarks and collect timing results.")
    parser.add_argument("--benchmark_dir", help="Path to the circom-benchmarks directory.", default=".")
    parser.add_argument("--timeout", type=float, default=2, help="Per-benchmark timeout in seconds.")
    parser.add_argument("--concrete", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--circom-bin", default="circom", help="Path to the circom binary.")
    args = parser.parse_args()
    print(args.benchmark_dir)
    files = get_circom_entrypoints(args.benchmark_dir)
    run_circom_benchmarks(
        files,
        args.benchmark_dir,
        timeout=args.timeout,
        concrete=args.concrete,
        circom_bin=args.circom_bin,
    )
