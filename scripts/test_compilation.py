#!/usr/bin/env python3
"""
Testing script for compilation coverage.

Receives a circom file to be sent to the compiler and an output path for the report.
"""

import os
import os.path
import click
import shutil
from tempfile import TemporaryDirectory
from typing import Optional, Tuple, Union
import json
import re
import subprocess
import time


def setup_dirs(src: str, out: str, tmp: Optional[str]) -> Tuple[str, str, Union[str, TemporaryDirectory]]:
    src = os.path.realpath(src)
    out = os.path.realpath(out)
    if tmp:
        tmp = os.path.realpath(tmp)
        shutil.rmtree(tmp) 
        os.mkdir(tmp)
    else:
        tmp = TemporaryDirectory()
    return src, out, tmp


class Report:
    def __init__(self, src: str, cmd: str, execution: subprocess.CompletedProcess, run_time: float):
        self.src = src
        self.cmd = cmd
        self.execution = execution
        self.run_time = run_time

    @property
    def successful(self):
        return self.execution.returncode == 0

    def to_dict(self) -> dict:
        return {
            'src': self.src,
            'cmd': self.cmd,
            'returncode': self.execution.returncode,
            'successful': self.successful,
            'stdout': escape_ansi(self.execution.stdout.decode("utf-8")),
            'stderr': escape_ansi(self.execution.stderr.decode("utf-8")),
            'run_time': self.run_time
        }


def escape_ansi(line: str) -> str:
    ansi_escape =re.compile(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]')
    return ansi_escape.sub('', line)


def run_test(src: str, tmp: str, circom: str, debug: bool) -> Report:
    cmd = [
        circom,
        '--llvm',
        '-o',
        tmp.name,
        src
    ]
    start = time.time()
    execution = subprocess.run(cmd, capture_output=True)
    end = time.time()
    if debug:
        if execution.returncode == 0:
            print("Success!")
        else:
            print("Failure!")
        if execution.stdout:
            print("Circom stdout:\n", escape_ansi(execution.stdout.decode("utf-8")))
        if execution.stderr:
            print("Circom stderr:\n", escape_ansi(execution.stderr.decode("utf-8")))
        print("Execution time in seconds:", end - start)

    return Report(src, cmd, execution, end - start)


@click.command()
@click.option('--src', help='Source file to be sent to the compiler.')
@click.option('--out', help='Location of the output report.')
@click.option('--tmp', help='Optional temporal directory.', default=None)
@click.option('--circom', help="Optional path to circom binary", default="circom")
@click.option('--debug', help="Print debug information", is_flag=True)
def main(src, out, tmp, circom, debug):
    src, out, tmp = setup_dirs(src, out, tmp)
    report = run_test(src, tmp, circom, debug)
    with open(out, 'w') as out_file:
        json.dump(report.to_dict(), out_file)

if __name__ == "__main__":
    main()