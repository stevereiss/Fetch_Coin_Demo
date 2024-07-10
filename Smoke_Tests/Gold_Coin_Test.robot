*** Settings ***
Documentation     A Smoke test suite with tests for Gold Bar Testing Exercise.
...
...               This test has a workflow that is created using keywords in
...               the imported resource file (in ../Common/).

Resource          ../Common/resource.robot                                      # use basic resource file
Resource          ../Common/resource_Gold_Coin.robot                            # use Gold Coin resource file
#Resource          ../Common/resource_SmokeTest.robot                            # use Smoke Test resource file

Test Setup        Suite Setup                                                   # run at Beginning of EACH TEST
Test Teardown     Suite Cleanup                                                 # run at end EACH TEST
Suite Teardown    Final Cleanup                                                 # run at end of SUITE


*** Variables ***
${USE_ALT_PROFILE}      ${False}                                                # set for Firefox download tests  - passed in on cmd-line
${USER}                 test                                                    # user name for the test - passed in on cmd-line
${PASSWORD}             test                                                    # password for the test  - passed in on cmd-line


*** Test Cases ***

Coin Test
    [Documentation]     Gold Coin Test
    [tags]              Smoke    Test

    ${Num_Bars}         Set Variable    ${9}

    Run Keyword And Continue on Failure      Gold Coin Test   ${Num_Bars}       # Run Gold Coing Test


