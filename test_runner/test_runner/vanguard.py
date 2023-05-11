"""Utilities for running vanguard"""
from pathlib import Path
import shutil
import subprocess
import logging
from typing import Dict, List, Tuple, Union

from test_runner.test_case import TestCase, TestCaseGroup

logger = logging.getLogger(__name__)

def check_circom2llvm_exists():
    """
    Check if the 'circom2llvm' executable exists in the system's PATH.

    Returns:
        True if the executable exists, False otherwise.
    """
    return shutil.which("circom2llvm") is not None

def check_vanguard_driver_exists():
    """
    Check if the 'vanguard_driver' executable exists in the system's PATH.

    Returns:
        True if the executable exists, False otherwise.
    """
    return shutil.which("vanguard_driver") is not None

def run_vanguard_driver_on_test_case_group(test_case_group: TestCaseGroup) -> List[Dict[str, str]]:
    """
    Run the 'vanguard_driver' executable on the specified test case

    Args:
        test_case_group: the test case group
    """
    results = []
    for test_case in test_case_group.tests:
        (success, output) = run_vanguard_driver(test_case_group.root_dir / "src", test_case)
        result = {
            "group_id": str(test_case_group.id),
            "group_dir": str(test_case_group.root_dir),
            "test_case_id": str(test_case_group.id),
            "test_case_file": str(test_case.file),
            "test_case_main": str(test_case.main),
            "test_case_template": str(test_case.template),
            "success": str(success),
        }
        results.append(result)
        # TODO: Record output
    return results


def run_vanguard_driver(src_dir: Path, test_case: TestCase) -> Tuple[bool, str]:
    """
    Run the 'vanguard_driver' executable on the specified test case

    Args:
        file_path: The path to the file to be processed.

    Returns:
        (bool, str): true if successful, along with output
    """
    executable_name = "vanguard_driver"

    # Check if the executable exists
    if not check_vanguard_driver_exists():
        print(f"Executable '{executable_name}' not found.")
        return

    # Run the executable with the file as an argument
    file_path: Path = src_dir / test_case.file
    file_name = str(file_path)
    cmd = [executable_name, file_name, "--detector", "all", "--base-dir", str(src_dir)]
    logger.debug("Running command: %s", cmd)
    try:
        completed_process = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output = completed_process.stdout.decode("utf-8")
        success = "Aborting Vanguard run!" in output
        if not success:
            logger.debug("Error running '%s' on '%s'", executable_name, file_name)
        else:
            logger.debug("Successfully ran %s on file %s.", executable_name, file_name)
        return (success, output)
    except subprocess.CalledProcessError as _exc:
        assert False, "Vanguard driver handles errors internally currently."
        # logger.debug("Error running '%s': %s", executable_name, exc)
        # return exc
