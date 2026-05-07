"""
Multi-environment configuration for learning-lab tutorial suites.

Usage in a suite Settings section:
    Variables    ${CURDIR}/../data/environments.py

This gives access to ${ENVIRONMENTS}, ${BASE_URL}, ${API_URL}, ${BROWSER},
${TIMEOUT} — all resolved to the 'dev' defaults, overridable at runtime.
"""

ENVIRONMENTS = {
    "dev": {
        "base_url": "https://dev.example.test",
        "api_url":  "https://dev-api.example.test",
        "browser":  "chrome",
        "timeout":  10,
    },
    "staging": {
        "base_url": "https://staging.example.test",
        "api_url":  "https://staging-api.example.test",
        "browser":  "firefox",
        "timeout":  15,
    },
}

# Top-level exports so they work as direct ${VAR} references in tests
BASE_URL  = ENVIRONMENTS["dev"]["base_url"]
API_URL   = ENVIRONMENTS["dev"]["api_url"]
BROWSER   = ENVIRONMENTS["dev"]["browser"]
TIMEOUT   = ENVIRONMENTS["dev"]["timeout"]
