*** Settings ***
Resource    ../common/browser.resource

*** Variables ***
${CHECKOUT_TITLE}       css:[data-testid="checkout-title"]
${CHECKOUT_PRODUCT}     css:[data-testid="checkout-product"]
${CHECKOUT_QUANTITY}    css:[data-testid="checkout-quantity"]
${CHECKOUT_TERMS}       css:[data-testid="checkout-terms"]
${CHECKOUT_SUBMIT}      css:[data-testid="checkout-submit"]
${CHECKOUT_ERROR}       css:[data-testid="checkout-error"]
${CHECKOUT_SUCCESS}     css:[data-testid="checkout-success"]
${CHECKOUT_STATUS}      css:[data-testid="checkout-status"]

*** Keywords ***
Checkout Should Be Visible
    Wait Until Element Is Visible    ${CHECKOUT_TITLE}    timeout=5s
    Element Text Should Be    ${CHECKOUT_TITLE}    Checkout

Complete Checkout
    [Arguments]    ${product}=Pro Plan    ${quantity}=2
    Select From List By Label    ${CHECKOUT_PRODUCT}    ${product}
    Clear Element Text    ${CHECKOUT_QUANTITY}
    Input Text    ${CHECKOUT_QUANTITY}    ${quantity}
    Select Checkbox    ${CHECKOUT_TERMS}
    Click Button    ${CHECKOUT_SUBMIT}

Submit Checkout Without Terms
    Click Button    ${CHECKOUT_SUBMIT}

Order Confirmation Should Be Visible
    Wait Until Element Is Visible    ${CHECKOUT_SUCCESS}    timeout=5s
    Element Text Should Be    ${CHECKOUT_SUCCESS}    Bestellung wurde abgeschlossen.
    Element Text Should Be    ${CHECKOUT_STATUS}    Abgeschlossen

Checkout Terms Error Should Be Visible
    Wait Until Element Is Visible    ${CHECKOUT_ERROR}    timeout=5s
    Element Text Should Be    ${CHECKOUT_ERROR}    Die AGB muessen akzeptiert werden.

