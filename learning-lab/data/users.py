"""
Mock user data for tutorial suites.
"""

ADMIN_USER = {
    "username": "admin",
    "password": "secret",
    "role":     "admin",
}

READONLY_USER = {
    "username": "viewer",
    "password": "viewonly",
    "role":     "readonly",
}

# Ordered list of mock users for iteration exercises
TEST_USERS = [
    {"username": "alice", "role": "viewer"},
    {"username": "bob",   "role": "editor"},
    {"username": "carol", "role": "admin"},
]

# Pre-built invalid-credential rows for data-driven login tests
INVALID_USERS = [
    {"username": "wrong_user",  "password": "secret",       "message": "Invalid username or password"},
    {"username": "admin",       "password": "wrong_password","message": "Invalid username or password"},
    {"username": "",            "password": "",              "message": "Username is required"},
]
