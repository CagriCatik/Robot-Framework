ENVIRONMENTS = {
    "dev": {
        "base_url": "https://dev.example.test",
        "api_url": "https://dev-api.example.test",
        "browser": "chrome",
        "timeout": 10,
    },
    "staging": {
        "base_url": "https://staging.example.test",
        "api_url": "https://staging-api.example.test",
        "browser": "firefox",
        "timeout": 15,
    },
}

BASE_URL = ENVIRONMENTS["dev"]["base_url"]
API_URL = ENVIRONMENTS["dev"]["api_url"]
BROWSER = ENVIRONMENTS["dev"]["browser"]
TIMEOUT = ENVIRONMENTS["dev"]["timeout"]

