*** Settings ***
Documentation    Test suite demonstrating the use of OpenCV and EasyOCR via a custom Python Library.
Library          ../libraries/VisionLibrary.py
Library          OperatingSystem

*** Variables ***
${IMAGE_DIR}      ${CURDIR}/../data
${SCREEN_IMG}     ${IMAGE_DIR}/screen.png
${TEMPLATE_IMG}   ${IMAGE_DIR}/template.png

*** Test Cases ***
Verify Text Is Detected In Image
    [Documentation]    Uses EasyOCR to verify that the word 'Climate' appears in the generated screen image.
    [Tags]             vision    ocr
    Image Should Contain Text    ${SCREEN_IMG}    Climate

Extract All Text From Image
    [Documentation]    Uses EasyOCR to extract all text and log it.
    [Tags]             vision    ocr
    ${texts}=    Get Text From Image    ${SCREEN_IMG}
    Log    Detected texts: ${texts}

Verify Template Exists In Image
    [Documentation]    Uses OpenCV to find the red button template inside the larger screen image.
    [Tags]             vision    opencv
    Image Should Contain Template    ${SCREEN_IMG}    ${TEMPLATE_IMG}    threshold=0.8

Get Coordinates Of Template
    [Documentation]    Uses OpenCV to find the exact coordinates of the template to simulate a click.
    [Tags]             vision    opencv
    ${x}    ${y}=    Get Template Coordinates    ${SCREEN_IMG}    ${TEMPLATE_IMG}    threshold=0.8
    Log    Template found at X: ${x}, Y: ${y}
    # In a real test, you might use PyAutoGUI or Appium to click these coordinates!
