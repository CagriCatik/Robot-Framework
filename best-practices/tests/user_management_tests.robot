*** Settings ***
Resource          ../resources/common/browser.resource
Resource          ../resources/common/test_data.resource
Resource          ../resources/pages/login_page.resource
Resource          ../resources/pages/dashboard_page.resource
Resource          ../resources/pages/users_page.resource
Library           ../libraries/TestDataGenerator.py
Suite Setup       Open Test Browser
Suite Teardown    Close Test Browser
Test Setup        Start Logged In Session

*** Test Cases ***
Admin Can Create New User
    [Tags]    TC_06_Admin_can_create_new_user    UserManagement
    Open User Management
    ${random_name}=     Get Random Name
    ${random_email}=    Get Random Email
    Create User    ${random_name}    ${random_email}    Editor
    User Row Should Be Visible    ${random_name}
    Capture Page Screenshot    screenshots/user_created.png

Admin Can Search Existing User
    [Tags]    TC_07_Admin_can_search_existing_user    UserManagement
    Open User Management
    Search User    ${EXISTING_USER_NAME}
    User Row Should Be Visible    ${EXISTING_USER_NAME}
    User Row Should Not Be Visible    ${SECOND_USER_NAME}
    Capture Page Screenshot    screenshots/user_searched.png

Admin Can Edit Existing User
    [Tags]    TC_08_Admin_can_edit_existing_user    UserManagement
    Open User Management
    Open Edit Form For User    ${EXISTING_USER_NAME}
    Change User Name To    ${UPDATED_USER_NAME}
    Submit User Form
    Success Message Should Be    Benutzer wurde aktualisiert.
    User Row Should Be Visible    ${UPDATED_USER_NAME}
    User Row Should Not Be Visible    ${EXISTING_USER_NAME}
    Capture Page Screenshot    screenshots/user_edited.png

Admin Can Delete Existing User
    [Tags]    TC_09_Admin_can_delete_existing_user    UserManagement
    Open User Management
    Delete User    ${SECOND_USER_NAME}
    User Row Should Not Be Visible    ${SECOND_USER_NAME}
    Capture Page Screenshot    screenshots/user_deleted.png

User Cannot Save Form Without Required Fields
    [Tags]    TC_10_User_cannot_save_form_without_required_fields    UserManagement
    Open User Management
    Submit User Form
    User Form Error Should Be Visible
    Capture Page Screenshot    screenshots/user_form_error.png

*** Keywords ***
Start Logged In Session
    Reset Demo App State
    Login As Valid User

