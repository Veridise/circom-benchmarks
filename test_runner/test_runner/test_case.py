"""Test case dataclass"""
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

logger = logging.getLogger(__name__)

@dataclass
class TestCaseGroup:
    """Group of test cases"""
    root_dir: Path
    id: Optional[str]
    source: Optional[str]
    internal: Optional[bool]
    project_url: Optional[str]
    commit: Optional[str]
    synthetic: Optional[bool]
    tests: List['TestCase']  # List of SubTestCase objects

@dataclass
class TestCase:
    """Test case in a particular group"""
    id: Optional[str]
    file: str
    template: str
    main: str
    description: str

def check_keys(required_keys: List[str], optional_keys: List[str], keys: List[str], file_name: Union[str,Path]):
    """Check that keys are in the JSON data

    Args:
        required_keys (List[str]): required keys
        optional_keys (List[str]): optional keys
        keys (List[str]): keys from the data
        file_name (str): file holding the data

    Raises:
        ValueError: if any required keys are missing
    """
    missing_keys = [key for key in required_keys if key not in keys]
    if missing_keys:
        raise ValueError(f"JSON file {str(file_name)} is missing required keys: {missing_keys}")
    missing_optional_keys = [key for key in optional_keys if key not in keys]
    if missing_optional_keys:
        logger.warning("JSON file %s missing optional keys %s", str(file_name), missing_optional_keys)

def json_to_test_case(path: Path, json_data: Dict[str, Any]) -> TestCaseGroup:
    """
    Convert JSON data to a TestCase object.

    Args:
        path: path to json file
        json_data: The JSON data to convert.

    Returns:
        A TestCaseGroup object.

    Raises:
        ValueError: If the JSON data is missing any required key.
    """
    required_keys = ['tests']
    optional_keys = ['id', 'source', 'internal', 'project_url', 'commit', 'synthetic', 'tests']
    check_keys(required_keys=required_keys, optional_keys=optional_keys, keys=json_data,
               file_name=str(path))

    test_cases = []
    for sub_test_case_data in json_data['tests']:
        required_test_keys = ['main', 'file', 'template', 'description']
        optional_test_keys = ['id']
        check_keys(required_keys=required_test_keys,
                   optional_keys=optional_test_keys,
                   keys=sub_test_case_data,
                   file_name=str(path))
        sub_test_case = TestCase(
            id=sub_test_case_data.get('id'),
            file=sub_test_case_data['file'],
            template=sub_test_case_data['template'],
            main=sub_test_case_data['main'],
            description=sub_test_case_data['description']
        )
        test_cases.append(sub_test_case)

    return TestCaseGroup(
        root_dir=path.parent,
        id=json_data.get('id'),
        source=json_data.get('source'),
        internal=json_data.get('internal'),
        project_url=json_data.get('project_url'),
        commit=json_data.get('commit'),
        synthetic=json_data.get('synthetic'),
        tests=test_cases
    )


