*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported Extended SeleniumLibrary.


Library           Collections
Library           String
Library           DateTime
Library           OperatingSystem
Library           SeleniumLibrary

Library           Faker_Data_Generator.py                                    # custom python library

Variables         locators.py                                                # Global Variables - IN ALL CAPS - in python formatted file


*** Variables ***


# URL info
${NUM_COINS}        8                                                          # set default num of coins - use CMD-LINE to change
${SERVER}           sdetchallenge.fetch.com                                    # Testing URL
${URL_PARAM}        ?coins=${NUM_COINS}                                        # added param - sets number of coins

${PROTOCOL}         http                                                       # default protocol is non-secure
${BASE_URL}         ${PROTOCOL}://${SERVER}/${URL_PARAM}
${DEFAULT_TITLE}    React App                                                  # partial match on page title version

${EQUAL_VALUE}      =                                                          # Comparison Operators
${LESS_VALUE}       <
${GREATER_VALUE}    >


*** Keywords ***

Suite Setup
    [Documentation]     Initialize the environment for Suite - run at beginning of test


    Test Initialization                                                                     # perform initialization tests


Suite Cleanup
    [Documentation]     Cleanup for Test - run at end of Each Test


    SeleniumLibrary.Close All Browsers                                                       # close the browser

    ${msg_length}   Get Length  ${TEST MESSAGE}

    Log     ${TEST MESSAGE}
    Log     ${msg_length}


    Run Keyword If    ${msg_length} > 0     Append To List    ${MESSAGE_LIST}        ${TEST MESSAGE}


Final Cleanup
    [Documentation]     Cleanup for Suite - run at end of Suite


    ${output_message}       Catenate    SEPARATOR=${\n}    @{MESSAGE_LIST}         # convert LIST to string + CR per line
    ${message_length}       Get Length    ${output_message}
    ${data_length}          Get Length    ${DATA_LIST}


    IF    ${data_length} > 0                                                        # if there is data to output

        Log To Console    DATA_BEGIN                                                # Begin Data

        FOR    ${curr_row}  IN    @{DATA_LIST}
            Log To Console      ${TWO_SPACES}${curr_row}
            Log To Console      ${EMPTY}
        END

        Log List        ${DATA_LIST}


        Log To Console    DATA_END                                                  # End Token
        Log To Console    ${EMPTY}                                                  # blank line

    END

    # Output to console - will get picked up by Slack Message

    Log To Console    INFO_BEGIN                                                # Output - Begin Token

    Log To Console    Tested Server : ${SERVER}
    Log To Console    ${SPACE*7} Suite : ${SUITE_NAME}
    Log To Console    ${SPACE*5} Browser : ${BROWSER}
    Log To Console    ${EMPTY}


#    Log To Console    Test Stats${SPACE*3} : ${SUITE MESSAGE}
#    Log To Console    ${EMPTY}

    IF  ${message_length} > 1
        Log To Console    ${output_message}
    END


    Log To Console    INFO_END                                                      # Output - End Token


Test Initialization
    [Documentation]     Perform User Login - present UserName/Password on login screen
#    [Arguments]         ${UserName}      ${Password}     ${Alt_Profile}


    Open Browser To Base Page

    Run Keyword And Continue On Failure     Check Base URL


Base Page Should Be Open
    [Documentation]     Validate the page of the login screen

    ${page_title}       SeleniumLibrary.Get Title
    Should Contain      ${page_title}   ${DEFAULT_TITLE}                                    # pattern match version to title


Check Base URL

    ${current_location}     SeleniumLibrary.Get Location

    Should Contain          ${current_location}  ${BASE_URL}   msg=Base URL is Incorrect                   # Validate url & title



Input Test Values
    [Documentation]     Fill in LEFT & RIGHT side bowl values
    [Arguments]         ${left_value}    ${right_value}

    SeleniumLibrary.Clear Element Text    ${LEFT_INPUT_BOX}

    SeleniumLibrary.Input Text    ${LEFT_INPUT_BOX}    ${left_value}              # Enter the LEFT value on screen

    Sleep     1s

    SeleniumLibrary.Clear Element Text   ${RIGHT_INPUT_BOX}
    SeleniumLibrary.Input Text           ${RIGHT_INPUT_BOX}   ${right_value}      # Enter the RIGHT value on screen

    Sleep     1s

    SeleniumLibrary.Click Button    ${WEIGH_BUTTON}                            # Click WEIGH button on screen

    Sleep     3s

    #${result_text}    Run Keyword and Ignore Error    SeleniumLibrary.Get Text    ${WEIGHING_TEXT}
    ${result_text}    Run Keyword     SeleniumLibrary.Get Text    ${WEIGHING_TEXT}

    @{Split_Values}   Split String    ${result_text}    \n

    ${the_result}    Get From List    ${Split_Values}    -1

#    Log To Console    Result Text : ${the_result}

    RETURN    ${the_result}


Select Coin Value
    [Documentation]     Click on The Fake Value from the Coin Row
    [Arguments]         ${fake_value}

    ${num_value}        Evaluate    int(re.search("\\d+","${fake_value}")[0])     modules=re        # get the integer from value : [1] = 1

    ${coin_locator}     Set Variable     xpath=//button[@id='coin_${num_value}']                    # create the coin locator

    Run Keyword And Continue on Failure     SeleniumLibrary.Click Button   ${coin_locator}          # click the [N] button - found coin!

    Sleep    4s

    SeleniumLibrary.handle alert    action=DISMISS    timeout=10s                                   # Dismiss the Dialog Box

    Log To Console      ${\n}Dialog Box Dismissed!${\n}


Gold Coin Test
    [Documentation]     Select Left-side Menu items by MenuItem
    [Arguments]         ${Num_Items}

    Log To Console      ${\n}Number of Gold Bars : ${Num_Items}${\n}

    ${base_list}        evaluate   [x for x in range(0, ${Num_Items})]      # generate base list
    ${test_list}        evaluate   [x for x in range(1, ${Num_Items})]      # generate test list

#    Log To Console     Base_List : ${base_list}
#    Log To Console     Test_List : ${test_list}


    #    TESTING LOOP - Put 1 value in LEFT & Right Side Scales

    FOR    ${current_value}      IN RANGE   ${Num_Items}

        TRY
            ${left_value} 	    Remove From List	${base_list}    0       # POP 1st value from each list
            ${right_value} 	    Remove From List	${test_list}    0
        EXCEPT                                                              # error getting values
            ${the_fake_value}    Evaluate    ${Num_Items} - 1               # set to num_items -1
            BREAK
        END

#        Log To Console      Testing Values : ${left_value} | ${right_value}${\n}

        ${test_result}      Run Keyword    Input Test Values    ${left_value}    ${right_value}

#        log to console     Test Result : ${test_result}

        ${contains}    Run Keyword And Return Status    Should Contain   ${test_result}    ${EQUAL_VALUE}       # are the bars EQUAL ?

        IF  ${contains} == ${True}                                                          # BOTH Bars are REAL - Continue Loop
            ${list_len}    Get Length  ${base_list}

            IF    ${list_len} > 2
                Remove From List	${base_list}    0                                       # POP both list values - speed up choices
                Remove From List	${test_list}    0
            END

            Continue For Loop                                                               # now continue
        END

        Log To Console    ${\n}Found Fake : ${test_result}

        @{Split_Values}    Split String    ${test_result}                                   # split the result text get list - [[0], [<], [1]]
        ${the_operator}    Get From List    ${Split_Values}    1                            # get the operator: < = >

        IF    "${the_operator}" == "${LESS_VALUE}"                                          # is it LESS THAN?
            ${fake_num}    Set Variable    ${0}                                             # it is LESS THAN - use index 0
        ELSE
            ${fake_num}    Set Variable    ${2}                                             # it is GREATER THAN - use index 2
        END

        ${the_fake_value}    Get From List    ${Split_Values}    ${fake_num}                # get the FAKE value

        Log To Console    ${\n}Found Fake Value : ${the_fake_value}

        ${result_text}    Run Keyword     SeleniumLibrary.Get Text    ${WEIGHING_TEXT}      # get the Weighing text on screen

        Log To Console      ${\n}Bars Tested:${\n}${result_text}${\n}                       # output weighing text to screen

        BREAK

    END

    Select Coin Value    ${the_fake_value}                                                  # click on the Fake Coin
