import re
import sys
from datetime import datetime
from pathlib import Path


class LearningTools:
    """Custom tutorial keywords used by the example Robot Framework project."""

    def get_robot_version(self):
        from robot.version import get_version

        return get_version()

    def get_python_executable(self):
        return sys.executable

    def get_file_uri(self, path):
        return Path(path).resolve().as_uri()

    def normalize_label(self, value):
        return " ".join(str(value).strip().split()).title()

    def slugify(self, value):
        normalized = re.sub(r"[^a-zA-Z0-9]+", "-", str(value).strip().lower())
        return normalized.strip("-")

    def is_even(self, value):
        return int(value) % 2 == 0

    def get_environment_config(self, environments, name="dev"):
        try:
            return environments[name]
        except KeyError as exc:
            available = ", ".join(sorted(environments))
            raise AssertionError(f"Unknown environment '{name}'. Available: {available}") from exc

    def build_api_response(self, status_code=200, payload=None):
        if payload is None:
            payload = {}
        return {
            "status_code": int(status_code),
            "payload": payload,
            "received_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
        }

    def calculate_discount(self, amount, percent):
        return round(float(amount) * (float(percent) / 100), 2)

    def parse_number(self, value):
        match = re.search(r"-?\d+(?:\.\d+)?", str(value))
        if not match:
            raise AssertionError(f"No number found in '{value}'")
        number = float(match.group(0))
        if number.is_integer():
            return int(number)
        return number

    def required_keys_should_exist(self, mapping, *keys):
        missing = [key for key in keys if key not in mapping]
        if missing:
            raise AssertionError(f"Missing keys: {', '.join(missing)}")
        return True
