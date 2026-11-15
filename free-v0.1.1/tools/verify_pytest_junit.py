"""Verify exact case names and that no cases were skipped. Standard library only."""
from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def verify(report: Path, expected: set[str]) -> None:
    tree = ET.parse(report)
    cases = tree.findall('.//testcase')
    found = [case.attrib.get('name', '') for case in cases]
    if len(found) != len(expected) or set(found) != expected:
        raise ValueError(f'Wrong test collection: expected={sorted(expected)}, found={sorted(found)}')
    bad = [c.attrib.get('name', '') for c in cases if any(c.find(k) is not None for k in ('failure', 'error', 'skipped'))]
    if bad:
        raise ValueError(f'Failed or skipped test(s): {bad}')
    print(f'QA_SK_002_JUNIT_OK | TESTS={len(found)} | SKIPPED=0 | FAILURES=0')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        raise SystemExit('Usage: verify_pytest_junit.py report.xml test_name [test_name...]')
    try:
        verify(Path(sys.argv[1]), set(sys.argv[2:]))
    except (ET.ParseError, OSError, ValueError) as exc:
        print(f'QA_SK_002_JUNIT_BLOCKED: {exc}', file=sys.stderr)
        raise SystemExit(2) from exc
