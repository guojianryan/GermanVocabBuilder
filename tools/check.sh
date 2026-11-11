#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
# Activate a Python environment containing jsonschema before running.
python3 tools/validate.py lessons/[abc][12]/*.json
swiftc -module-cache-path /tmp/wortschatz-swift-cache Wortschatz/Core/Lessons.swift Tests/CoreTests.swift -o /tmp/wortschatz-core-tests
/tmp/wortschatz-core-tests
