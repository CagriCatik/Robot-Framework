ADMIN_USER = {
    "username": "admin",
    "password": "secret",
    "role": "admin",
}

READONLY_USER = {
    "username": "viewer",
    "password": "viewonly",
    "role": "readonly",
}

INVALID_USERS = [
    {"username": "wrong_user", "password": "secret", "message": "Invalid username or password"},
    {"username": "admin", "password": "wrong_password", "message": "Invalid username or password"},
    {"username": "", "password": "", "message": "Username is required"},
]

