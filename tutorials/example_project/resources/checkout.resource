*** Settings ***
Documentation    Business-level checkout keywords.
Resource         common.resource

*** Variables ***
${CART_ICON}             css:.cart-icon
${CHECKOUT_BUTTON}       id:checkout-btn
${PAYMENT_FORM}          id:payment-form
${ORDER_CONFIRMATION}    css:.order-confirmation

*** Keywords ***
Start Empty Cart
    ${cart}=    Create List
    Set Test Variable    ${CART_ITEMS}    ${cart}
    Set Test Variable    ${CHECKOUT_STATUS}    browsing

Add Product To Cart
    [Arguments]    ${product}
    Append To List    ${CART_ITEMS}    ${product}
    Log    Added ${product} to cart.

Cart Should Contain
    [Arguments]    ${product}
    List Should Contain Value    ${CART_ITEMS}    ${product}

Proceed To Checkout
    Should Not Be Empty    ${CART_ITEMS}
    Log    Click ${CART_ICON}
    Log    Click ${CHECKOUT_BUTTON}
    Set Test Variable    ${CHECKOUT_STATUS}    checkout

Complete Payment With
    [Arguments]    ${payment_type}
    Should Be Equal    ${CHECKOUT_STATUS}    checkout
    Should Not Be Empty    ${payment_type}
    Log    Fill ${PAYMENT_FORM} using ${payment_type}
    Set Test Variable    ${CHECKOUT_STATUS}    confirmed

Order Confirmation Should Be Visible
    Should Be Equal    ${CHECKOUT_STATUS}    confirmed
    Log    Checking ${ORDER_CONFIRMATION}

