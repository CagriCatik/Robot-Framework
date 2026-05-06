class TextTools:
    """Small tutorial library exposed as Robot Framework keywords."""

    def normalize_label(self, value):
        return " ".join(value.strip().split()).title()

    def contains_ignore_case(self, text, expected):
        return expected.lower() in text.lower()