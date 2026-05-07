"""Custom Robot Framework keyword library for temperature-related assertions."""


class TemperatureUtils:
    """Utility keywords for temperature assertions in simulator tests."""

    def celsius_to_fahrenheit(self, celsius_str):
        """Converts '22°C' to 71.6 (float).

        Example:
            ${f}=    Celsius To Fahrenheit    22°C
            # returns 71.6
        """
        value = float(celsius_str.replace("°C", "").strip())
        return round(value * 9 / 5 + 32, 1)

    def temperature_is_in_range(self, celsius_str, low, high):
        """Returns True if the numeric part of celsius_str is between low and high (inclusive).

        Example:
            ${ok}=    Temperature Is In Range    22°C    16    30
            Should Be True    ${ok}
        """
        value = float(celsius_str.replace("°C", "").strip())
        return float(low) <= value <= float(high)

    def parse_temperature(self, celsius_str):
        """Returns the numeric part of '22°C' as a float.

        Example:
            ${num}=    Parse Temperature    22°C
            # returns 22.0
        """
        return float(celsius_str.replace("°C", "").strip())

    def parse_fan_speed(self, speed_str):
        """Returns the fan speed string as an integer.

        Example:
            ${speed}=    Parse Fan Speed    3
            # returns 3 (int)
        """
        return int(str(speed_str).strip())

    def temperatures_differ_by(self, temp_a_str, temp_b_str, expected_delta):
        """Returns True if the two temperatures differ by exactly expected_delta.

        Useful for asserting that clicking up N times raises the value by N.

        Example:
            ${ok}=    Temperatures Differ By    22°C    25°C    3
            Should Be True    ${ok}
        """
        a = float(temp_a_str.replace("°C", "").strip())
        b = float(temp_b_str.replace("°C", "").strip())
        return abs(b - a) == float(expected_delta)
