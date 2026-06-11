#!/usr/bin/env sh
set -eu

# Clean test flow for the FastAPI stack (excludes legacy Django tests).
python -W "ignore:Binding .* is a named parameter, but you supplied a sequence.*:DeprecationWarning" \
  -m unittest -q app.tests.test_api_smoke app.tests.test_e2e_functional_requirements
