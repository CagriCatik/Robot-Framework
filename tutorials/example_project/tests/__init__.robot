*** Settings ***
Documentation     Main suite for the tutorial example project.
Resource          ../resources/lifecycle.resource
Suite Setup       Start Tutorial Suite
Suite Teardown    End Tutorial Suite
Test Setup        Log    Starting test: ${TEST NAME}
Test Teardown     Log    Finished test: ${TEST NAME} with ${TEST STATUS}
Test Tags         tutorial-project
