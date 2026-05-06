import cv2
import easyocr
import numpy as np
import os
from robot.api.deco import library, keyword

@library(scope='GLOBAL')
class VisionLibrary:
    """
    A custom Robot Framework library for Computer Vision tasks.
    Uses OpenCV for template matching and EasyOCR for text detection.
    """

    def __init__(self):
        # We initialize the reader lazily to avoid loading the model if not needed
        self.reader = None

    def _get_reader(self):
        if self.reader is None:
            # Initialize EasyOCR for English
            print("Initializing EasyOCR Model (this may take a moment on first run)...")
            self.reader = easyocr.Reader(['en'])
        return self.reader

    @keyword("Get Text From Image")
    def get_text_from_image(self, image_path):
        """
        Reads all text from an image using EasyOCR.
        Returns a list of strings found in the image.
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found at path: {image_path}")

        reader = self._get_reader()
        # detail=0 returns just the text, not bounding boxes or probabilities
        results = reader.readtext(image_path, detail=0)
        return results

    @keyword("Image Should Contain Text")
    def image_should_contain_text(self, image_path, expected_text, ignore_case=True):
        """
        Fails if the expected_text is not found anywhere in the image.
        """
        found_texts = self.get_text_from_image(image_path)
        
        expected = expected_text.lower() if ignore_case else expected_text
        
        for text in found_texts:
            found = text.lower() if ignore_case else text
            if expected in found:
                print(f"Text '{expected_text}' found in image.")
                return True
                
        raise AssertionError(f"Text '{expected_text}' was NOT found in image '{image_path}'. Found texts: {found_texts}")

    @keyword("Get Template Coordinates")
    def get_template_coordinates(self, image_path, template_path, threshold=0.8):
        """
        Uses OpenCV Template Matching to find a small template image inside a larger image.
        Returns the (x, y) coordinates of the center of the matched area.
        Fails if no match is found above the confidence threshold (0.0 to 1.0).
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Source image not found: {image_path}")
        if not os.path.exists(template_path):
            raise FileNotFoundError(f"Template image not found: {template_path}")

        # Read images in grayscale
        img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        template = cv2.imread(template_path, cv2.IMREAD_GRAYSCALE)
        
        w, h = template.shape[::-1]

        # Perform template matching
        res = cv2.matchTemplate(img, template, cv2.TM_CCOEFF_NORMED)
        
        # Get the best match
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)

        if max_val >= float(threshold):
            # Calculate the center of the matched area
            center_x = max_loc[0] + w // 2
            center_y = max_loc[1] + h // 2
            print(f"Template matched with confidence {max_val:.2f} at center coordinates: ({center_x}, {center_y})")
            return center_x, center_y
        else:
            raise AssertionError(f"Template not found in image. Max confidence was {max_val:.2f} (required {threshold}).")

    @keyword("Image Should Contain Template")
    def image_should_contain_template(self, image_path, template_path, threshold=0.8):
        """
        Asserts that the template exists in the image with a confidence >= threshold.
        """
        # This will raise AssertionError if not found, fulfilling the "Should" requirement
        self.get_template_coordinates(image_path, template_path, threshold)
        return True
