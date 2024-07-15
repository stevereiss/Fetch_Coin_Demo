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
Library           RequestsLibrary

Library           Faker_Data_Generator.py                                    # custom python library
Variables         locators.py                                                # Global Variables - IN ALL CAPS - in python formatted file



*** Variables ***

${BROWSER}          Chrome                                                      # default browser to use
${BROWSER_VERSION}  ${EMPTY}
${DELAY}            .25                                                         # selenium delay - seconds

# Global User info

${USER}                 admin
${PASSWORD}             1
${HEADLESS_HEIGHT}      1920                                                     # screen height for headless browsers
${HEADLESS_WIDTH}       1080
${HEADLESS_BROWSER}     ${False}                                                 # set to False = GUI with screen
${JS_CONSOLE}           ${False}
${DRIVER_LOG_LEVEL}     3                                                        # Selenium Browser Driver Log Level (0=Warnings, 1=Errors, 3=Fatal)

# Quantamatics URL info

#${SERVER}               quantamatics.com                                             # server where Quantamatics is running - over-ride with cmd-line value
#${PROTOCOL}             https                                                        # default protocol is secure
#${EMAIL_DOMAIN}         @mailinator.com                                              # test email domain
#
#${ALT_FIREFOX_PROFILE}      Profiles${PATH_SEPERATOR}FireFoxAutomationUserProfile    # location of special FF profile - download tests
#${DATA_DIRECTORY}           ..${PATH_SEPERATOR}data${PATH_SEPERATOR}                 # location of data files
#${SCREENSHOT_DIRECTORY}     C:\Temp\Output\                                          # location of screenshot files
@{MESSAGE_LIST}
@{DATA_LIST}

${ONE_SPACE}            ${SPACE}
${TWO_SPACES}           ${SPACE*2}
${QUERY_SUCCESS}        ${0}
${QUERY_FAILURE}        ${0}
${VALIDATION_FAILURE}   ${0}
${SQL_FAILURE}          ${0}


*** Keywords ***

Open Browser To Base Page
    [Documentation]     Get the proper browser from variable BROWSER and set the correct options
#    [arguments]         ${Use_Alt_Profile}

    Sleep           1s

#    ${profile_location}     Set Variable   ${CURDIR}${PATH_SEPERATOR}${ALT_FIREFOX_PROFILE}
#    Log                     Profile Location = ${profile_location}


    IF  '${BROWSER}' == "Chrome"
        Log To Console                          ${\n}Running Chrome with Browser Options
        Run Keyword And Continue On Failure     Chrome Browser Options  ${BASE_URL}     # Chrome with Options

    ELSE IF  '${BROWSER}' == "Edge"                                                     # MS Edge Browser - set options
        Log To Console         ${\n}Running Edge with Options

        ${edge_arguments}                  Set Variable    add_argument("--inprivate");add_argument("--enable-chrome-browser-cloud-management");add_argument("--log-level=${DRIVER_LOG_LEVEL}")

        SeleniumLibrary.Open Browser       ${BASE_URL}    browser=${BROWSER}     options=${edge_arguments}

    ELSE
        SeleniumLibrary.Open Browser    ${BASE_URL}    browser=${BROWSER}              # open configured browser - GUI Mode - to the test URL
    END

    Sleep           5s

    ${version}              Run Keyword And Ignore Error      Get Browser Version     ${BROWSER}                  # get the browser version
    ${version}              Get From List       ${version}  -1                                                    # get the last value from list - the actual browser info

    Set Global Variable     ${BROWSER_VERSION}      ${version}

    Set Tags                ${BROWSER_VERSION}                                  # set browser version tag for test case
    Set Tags                Server = ${SERVER}                                  # set test environment for test case

    Run Keyword             Get Selenium Driver Info                            # get info on Selenium driver

    Run Keyword If  ${HEADLESS_BROWSER} == ${False}    SeleniumLibrary.Maximize Browser Window          # only maximize in real browser

    SeleniumLibrary.Set Selenium Speed      ${DELAY}

    Base Page Should Be Open


Get Selenium Driver Info
    [Documentation]     Get the currently active Selenium Driver information - use system call to get version info

    IF    '${BROWSER}' == "Edge"
        ${name_index}       Set Variable    ${39}
        ${driver_temp}=     Run OS Command   msedgedriver -v       # MS Edge driver info

    ELSE IF     '${BROWSER}' == "Chrome"
        ${name_index}       Set Variable    ${27}
        ${driver_temp}=     Run OS Command   chromedriver -v       # Chrome driver info

    ELSE IF     '${BROWSER}' == "Firefox"
        ${name_index}       Set Variable    ${27}
        ${driver_temp}=     Run OS Command   geckodriver -v       # FireFox driver info

    ELSE
        Return From Keyword
    END

    ${driver_name}       Get Substring    ${driver_temp}    0   ${name_index}    # get the driver info substring

    Set Tags             ${driver_name}                        # set the tag with driver name + version


Toggle Buttons
    [arguments]         ${test_name}     @{element_list}
    [Documentation]     Toggle an On Screen element - Click On / Click Off


    @{error_list}       Create List                                             # put failing strings here

    FOR   ${current_element}  IN  @{element_list}                              # iterate through the element list

        # 1st Click Of Element

        ${status1}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${current_element}    # click the on screen element

        Run Keyword If      not ${status1}       Append To List  ${error_list}   ${current_element}                  # add string to list if NOT found
        Sleep   5s

        # 2nd Click Of Element

        ${status2}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${current_element}    # click the on screen element

        Run Keyword If      not ${status2}       Append To List  ${error_list}   ${current_element}                  # add string to list if NOT found
        Sleep   5s

    END

    ${errors_found}     Get Length      ${error_list}                           # get the length of errors found

    # Check that the length of the error list - should be ZERO

    Should Be Equal as Integers    ${errors_found}  ${0}   On Screen Text Items NOT Found : ${error_list} Failing Test Page : ${test_name}


Get Boolean Value
    [Documentation]     Convert a value to a real boolean - True|False
    [Arguments]         ${the_value}

    ${the_boolean_value}       Convert To Boolean     ${the_value}                     # use python lib to convert boolean value

    RETURN    ${the_boolean_value}


Get Browser Version
    [Documentation]     Log the name + version and platform of the browser under test
    [Arguments]         ${browser_name}

    ${agentHeader}     Execute Javascript    return navigator.userAgent;        # get the agent string from browser via js
    LOG                USER AGENT HEADER=${agentHeader}

    ${browser_info}    get_browser_agent    ${agentHeader}                      # get browser info - use python lib

    LOG                Browser Version=${browser_info}     level=INFO

    RETURN           ${browser_info}


Remove Files From Download Dir
    [documentation]     Delete a given file pattern from browser download dir
    [Arguments]         ${file_pattern}


    ${download_dir}         Run Keyword    Get Download Directory

    ${reports_to_delete}    List Directory      ${download_dir}  pattern=${file_pattern}            # look for file_pattern in Downloads


    FOR   ${current_file}  IN  @{reports_to_delete}                                                 # delete the file(s) found in Downloads
        ${temp_filename}    Join Path       ${download_dir}  ${current_file}
        Remove File         ${temp_filename}
    END


Check File Exists
    [documentation]     Validate a given file exists
    [Arguments]         ${file_path}    ${expected_status}

    IF  ${expected_status}                                  # File Should exist
        File Should Exist       ${file_path}
    ELSE                                                    # File Should NOT exist
        File Should Not Exist   ${file_path}
    END


Run OS Command
    [Documentation]     Pass in a system command - send command and args
    [Arguments]         ${command_to_run}

   ${rc}  ${output}=     Run and Return RC and Output     ${command_to_run}

    Log         ${rc}
    Log         ${output}

    RETURN      ${output}


Scroll Page To Location
    [Arguments]    ${x_location}    ${y_location}

    Execute JavaScript    window.scrollTo(${x_location},${y_location})


Repeat Key
    [Documentation]     Press a given key num times
    [Arguments]         ${field_locator}  ${char_value}   ${num}

    Log   ${char_value}

    FOR  ${i}  IN RANGE  1  ${num}                                            # iterate num times
        SeleniumLibrary.Press Keys   ${field_locator}  ${char_value}           # enter the value
    END


Repeat Back Button
    [Documentation]     Navigate Browser BACK Button num times
    [Arguments]        ${num}

    FOR  ${i}  IN RANGE  1  ${num} + 1                                        # iterate num times
        SeleniumLibrary.Go Back                                               # Click Browser Back button
        Sleep   2s
    END


Browser Refresh Page
    [Documentation]     Perform a browser page refresh

#The main difference is as follows:

#window.location.reload() reloads the current page with POST data,
#window.location.href='your url' does not include the POST data.

#    Execute Javascript    window.location.reload(true);
    Execute Javascript    window.location.reload();
    Sleep                 5s


Search Field
    [Documentation]     Perform a search on a given field_name
    [Arguments]         ${field_name}   ${search_terms}  ${row_locator}    ${key_delay}=2

    ${field_present}   Run Keyword And Return Status    SeleniumLibrary.Page Should Contain Element   ${field_name}     # see if the field is on page
    Return From Keyword If  not ${field_present}        SeleniumLibrary.Field NOT found               ${field_name}     # element NOT visible return false


    ${row_length}   Get Length  ${row_locator}

    FOR   ${current_term}  IN  @{search_terms}                                  # iterate through the search terms

        Enter Keys Slowly   ${field_name}     ${current_term}   ${key_delay}    # type the term into search field - 1 char at a time
        Sleep               2s

        ${row_count}        Run Keyword If    ${row_length} > 1       SeleniumLibrary.Get Element Count   ${row_locator}                # the value will be 1+ the located rows (empty row)

        run keyword if      ${row_count} < 1     Run Keyword And Return Status  SeleniumLibrary.Page Should Contain   No results for    # check for error in middle of screen

        ${text_length}      Get Length        ${current_term}
        Repeat Key          ${field_name}  BACKSPACE  ${text_length} + 1                                                                # backspace over the chars to clear field

        Sleep               2s
    END

Enter Keys Slowly
    [Documentation]     Enter a string - 1 char at a time
    [Arguments]         ${field_name}   ${the_string}    ${key_delay}=2

    @{the_list}=  Convert To List   ${the_string}

    FOR   ${current_char}  IN  @{the_list}                                  # iterate through the search string
        SeleniumLibrary.Press Keys   ${field_name}  ${current_char}         # enter the char value, then wait
        Sleep       ${key_delay}s
    END


New Browser Tab
    [Documentation]     Open up a new browser tab
    [arguments]         ${new_url}

    @{win_titles_before}=       SeleniumLibrary.Get Window Titles
    ${url_status}               Set Variable    ${None}

#    SeleniumLibrary.Press Keys    ${HOME_ICON}      CTRL+t                                                   # send key combination : Ctrl-T  =  opens new tab in same browser
#    SeleniumLibrary.Press Keys    ${MAIN_BROWSER_WINDOW}              CTRL+t                                                   # send key combination : Ctrl-T  =  opens new tab in same browser
#    SeleniumLibrary.Press Keys    None              ${CTRL_T}                                                   # send key combination : Ctrl-T  =  opens new tab in same browser
#    SeleniumLibrary.Press Keys    None              CTRL+t                                                   # send key combination : Ctrl-T  =  opens new tab in same browser
#    SeleniumLibrary.Press Keys    None              \ue009 t                                                  # send key combination : Ctrl-T  =  opens new tab in same browser
#    SeleniumLibrary.Press Keys    None              t                                                   # send key combination : Ctrl-T  =  opens new tab in same browser
    SeleniumLibrary.Execute Javascript    window.open('')

    Sleep               10s

    ${win_titles_after}      SeleniumLibrary.Get Window Titles                                   # find all window titles
    ${win_handles}           SeleniumLibrary.Get Window Handles

    ${total_windows}     Get Length      ${win_titles_after}                                     # get the length of links_visited

    IF    ${total_windows} > 1
        ${new_window}       Get From List       ${win_handles}    -1                             # get LAST window name from list - should be NEW tab

        SeleniumLibrary.Switch Window       ${new_window}                                        # select the new window

        ${url_status}     Run Keyword And Return Status    SeleniumLibrary.Go To        ${new_url}                                                  # go to given url

        Sleep                               10s
    ELSE
        Log     New Tab NOT Opened - Tabs Currently Open : ${win_titles_after}

    END

    RETURN    ${url_status}


Close Browser Tab
    [Documentation]     Close A browser tab - Pass in the window title or window handle
    [arguments]         ${window_title}

    Log                 Closing Browser Tab : ${window_title}

    ${all_windows}      SeleniumLibrary.Get Window Titles                                       # find all window titles
    ${all_windows_hand}      SeleniumLibrary.Get Window Handles                                 # find all window handles

    ${status}           SeleniumLibrary.Switch Window       ${window_title}                                   # select the tab passed in
    Sleep               5s

    ${status}           Run Keyword And Return Status   SeleniumLibrary.Close Window                                                      # send key combination : Ctrl-W  =  close a tab in browser

    Sleep               5s

    RETURN    ${status}


Browser Scroll To Bottom
    [Documentation]     Scroll A browser window to the bottom of the page

    ${width}	${height}	seleniumlibrary.Get Window Size

    Execute Javascript    window.scroll(0, ${height});

    Sleep               2s


Browser Scroll To Top
    [Documentation]     Scroll A browser window to the top of the page

#    Execute Javascript    window.scroll(0, 0);
    SeleniumLibrary.Press Keys       None     CTRL+HOME                                         # move to top of Page

    Sleep               2s


Get Web Element Attributes
    [arguments]         ${web_element}
    [documentation]     Return the html attributes of a web_element in dictionary format

    ${visible}          Run Keyword And Return Status       Element Should Be Visible  ${web_element}

    Return From Keyword If  not ${visible}      ${False}                            # element NOT visible return false


    ${html_code}=       Get Element Attribute   ${web_element}@outerHTML            # get the html text of the obj

    ${attributes}       get_web_element_attribute_names   ${html_code}              # use external python script to get all html attributes

    Log Dictionary      ${attributes}

    RETURN            ${attributes}


Verify On Screen Text
    [arguments]      ${test_name}     @{search_term_list}
    [Documentation]  Validate a list of strings for on screen presents - fail if any string NOT found


    @{error_list}       Create List                                             # put failing strings here
#    ${page_source}=     SeleniumLibrary.Get Source

    FOR   ${current_item}  IN  @{search_term_list}                            # iterate through the string list
        ${status}           Run Keyword And Return Status  SeleniumLibrary.Page Should Contain   ${current_item}                      # check the text on screen
        Run Keyword If      not ${status}       Append To List  ${error_list}   ${current_item}              # add string to list if NOT found

#        ${status2}           Run Keyword And Return Status  ${page_source}   should contain   ${current_item}                 # check the text in string

    END

    ${errors_found}     Get Length      ${error_list}                           # get the length of errors found

    # Check that the length of the error list - should be ZERO

#    Run Keyword And Continue on Failure     Should Be Equal as Integers    ${errors_found}  ${0}   On Screen Text Items NOT Found : ${error_list} Failing Test : ${test_name}
    Should Be Equal as Integers    ${errors_found}  ${0}   Test : ${test_name} :: On Screen Text Item(s) NOT Found : ${error_list} Failing Test Page


Get Data Age
    [arguments]         ${date_string}      ${the_date_format}
    [Documentation]     Perform date math on date_string compared to current time. Return age of date.

    Return from Keyword If      '${date_string}' == '${EMPTY}'    Date String Is Empty

    # get the current Epoch value
    ${current_datetime} =       Get Current Date        result_format=${the_date_format}
    ${current_epoch}            Convert Date            ${current_datetime}  epoch   date_format=${the_date_format}

    # get the epoch date of date_string - return if this fails (value is empty)
    ${cell_epoch}=              Run Keyword And Ignore Error    Convert Date      ${date_string}  epoch   date_format=${the_date_format}
    ${status}=                  Get From List   ${cell_epoch}   0

    Return from Keyword If      '${status}' == 'FAIL'           Data Age Not Available      # conversion failed - return

    # perform the final calculations -
    ${epoch_value}=             Get From List   ${cell_epoch}       -1
    ${time_diff_secs}=          Run Keyword And Ignore Error        Evaluate    abs(${epoch_value} - ${current_epoch})
    ${final_secs}=              Get From List  ${time_diff_secs}    -1

    # convert the seconds to a time value : hh:mm:ss
    ${time_diff}=               RUN KEYWORD AND IGNORE ERROR        Convert Time    ${final_secs}  timer   exclude_millis=yes
    ${data_age}=                Get From List  ${time_diff}         -1

    RETURN    ${data_age}


Validate Data
    [arguments]         ${data_value}
    [Documentation]     Perform data validation

    Return from Keyword If      '${data_value}' == '${EMPTY}'    ${False}       # empty string - return False

    ${data_as_string}       Convert To String   ${data_value}                   # convert the data to a string
    ${data_length}          Get Length          ${data_as_string}               # get the length of the string

    ${valid}                Evaluate    ${data_length} > 0                      # test if data has a length

    RETURN    ${valid}                                                        # return the status


Get Browser Console Log Entries

    ${selenium}         Get Library Instance    SeleniumLibrary                                         # get the instance of SeleniumLibary
    ${webdriver}        Set Variable            ${selenium._drivers.active_drivers}[0]                  # get the webdriver
    ${log_entries}      Evaluate                $webdriver.get_log('browser')                           # get the JS log entries from browser

    ${data_length}      Get Length    ${log_entries}

    IF    ${data_length} > 0                                                                            # Get the JS Console Log Data

        Insert Into List    ${log_entries}      0       JS Console Log Entries for TEST :: ${TEST_NAME} :\n     # add the test name as 1st entry
        Append To List     ${log_entries}       ${EMPTY}                                                        # add blank line as last entry

#        Log List        ${log_entries}                                                                  # send the log entries to log - 1 per line

        FOR    ${current_item}    IN    @{log_entries}

            TRY
                ${temp}         evaluate            $current_item.get("message", "")                                  # get just the message key from dict
                ${temp}         Run Keyword and Continue on Failure     Remove String       ${temp}    \"
                ${temp}         Run Keyword and Continue on Failure     Set Variable     ${temp}[0:200]

                IF    "${temp}" != "None"

                    ${in_list}    Run Keyword and Return Status    List Should Contain Value    ${DATA_LIST}    ${temp}

                    IF    ${in_list} == ${False}
                        Append to List   ${DATA_LIST}      ${TWO_SPACES}${temp}        # add current JS Logs to Global List
                    END

                END

            EXCEPT
                Append to List   ${DATA_LIST}       ${current_item}                                                     # add current JS Logs to Global List
            END

        END

        Log List    ${DATA_LIST}

    END


Chrome Browser Options
    [Documentation]     Create Chrome With Browser Options - Needs separate command-line arguments
    [arguments]         ${the_url}

   ${Win_Dir}       Set Variable    C:\\Windows\

   Append To Environment Variable    PATH    ${Win_Dir}

   #${CHROME_OPTIONS} =    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
   #${CHROME_OPTIONS}     Evaluate    selenium.webdriver.ChromeOptions()
   ${CHROME_OPTIONS}     Evaluate    selenium.webdriver.chrome.options.Options()                # new call for Selenium

#   ${prefs} =    create dictionary    download.prompt_for_download=${FALSE}    download.directory_upgrade=${TRUE}    download.default_directory=${OUTPUT_DIR}   safebrowsing.enabled=${TRUE}
#   call method    ${CHROME_OPTIONS}    download.prompt_for_download=${FALSE}
#   Call Method    ${CHROME_OPTIONS}    add_argument     download.prompt_for_download=${FALSE}

#       suppressing "This type of file can harm your computer." popup
#        prefs.put("safebrowsing.enabled", "false");
#download.default_directory  X
#download.prompt_for_download X
#download.extensions_to_open X
#safebrowsing.enabled X
#As well as add the following arguments to whilelist:
#--safebrowsing-disable-download-protection
#safebrowsing-disable-extension-blacklist

   Call Method    ${CHROME_OPTIONS}    add_argument     --excludeSwitches
   Call Method    ${CHROME_OPTIONS}    add_argument     --disable-logging
   Call Method    ${CHROME_OPTIONS}    add_argument     --log-level\=${DRIVER_LOG_LEVEL}
   Call Method    ${CHROME_OPTIONS}    add_argument     --safebrowsing-disable-download-protection
   Call Method    ${CHROME_OPTIONS}    add_argument     --safebrowsing-disable-extension-blacklist
   Call Method    ${CHROME_OPTIONS}    add_argument     --ignore-certificate-errors
   Call Method    ${CHROME_OPTIONS}    add_argument     --disable-webgl
   Call Method    ${CHROME_OPTIONS}    add_argument     --no-sandbox
   Call Method    ${CHROME_OPTIONS}    add_argument     --disable-background-mode
# download.default_directory=${OUTPUT_DIR}

   ${prefs} =    create dictionary    download.prompt_for_download=${FALSE}    download.directory_upgrade=${TRUE}      safebrowsing.enabled=${False}   download.extensions_to_open=${EMPTY}      excludeSwitches=${FALSE}     enable-logging=${False}

   Call Method    ${CHROME_OPTIONS}    add_experimental_option    prefs    ${prefs}


   #SeleniumLibrary.Create Webdriver    Chrome    chrome_options=${CHROME_OPTIONS}
   SeleniumLibrary.Create Webdriver    Chrome    options=${CHROME_OPTIONS}                      # new call for Selenium

   SeleniumLibrary.Go To               ${the_url}                                              # go to login page


ChromeHeadless
    [Documentation]     Create Chrome Headless - Needs separate command-line arguments
    [arguments]     ${the_url}

#    ${chrome_options} =     Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
   ${chrome_options}     Evaluate    selenium.webdriver.chrome.options.Options()                # new call for Selenium

    Call Method    ${chrome_options}   add_argument    headless
    Call Method    ${chrome_options}   add_argument    disable-gpu
    Call Method    ${chrome_options}   add_argument    ignore-certificate-errors
    Call Method    ${chrome_options}   add_argument    disable-web-security
    Call Method    ${chrome_options}   add_argument    allow-running-insecure-content
    Call Method    ${chrome_options}   add_argument    test-type
    Call Method    ${chrome_options}   add_argument    allow-insecure-localhost
#    Call Method    ${chrome_options}   add_argument    deterministic-fetch    # was causing Failures
    Call Method    ${chrome_options}   add_argument    enable-crash-reporter
    Call Method    ${chrome_options}   add_argument    ssl-protocol
    Call Method    ${chrome_options}   add_argument    ignore-ssl-errors
    Call Method    ${chrome_options}   add_argument    reduce-security-for-testing
    Call Method    ${chrome_options}   add_argument    disable-extensions

    SeleniumLibrary.Create Webdriver    Chrome    options=${chrome_options}              # create the driver

    SeleniumLibrary.Set Window Size    ${HEADLESS_HEIGHT}   ${HEADLESS_WIDTH}                                   # set the window size

    ${DELAY}            Set Variable      1                                                     # set delay to 1 sec

    SeleniumLibrary.Go To      ${the_url}                                                       # go to login page


Chrome Console Log
    [Documentation]     Create Chrome with JS Console - Needs separate command-line arguments
    [arguments]         ${the_url}

    ${chrome_options} =     Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver

    Call Method         ${chrome_options}   add_argument     enable-logging
    Call Method         ${chrome_options}   add_argument     v\=1
    Call Method         ${chrome_options}   add_argument     --auto-open-devtools-for-tabs


    Create Webdriver    Chrome    options=${chrome options}              # create the driver
    Sleep               5s

    Go To               ${the_url}                                              # go to login page

    Sleep               10s

#    SeleniumLibrary.Press Keys     None    SHIFT+CTRL+J
    SeleniumLibrary.Press Keys     ${MAIN_BROWSER_WINDOW}    SHIFT+CTRL+J          # send key combination : SHIFT Ctrl-J  =  opens Javascript console on DevTools
    Sleep               3s

    SeleniumLibrary.Press Keys     ${MAIN_BROWSER_WINDOW}    CTRL+L                # send key combination : SHIFT Ctrl-L  =  clear Javascript console
    Sleep               3s

FirefoxHeadless
    [Documentation]     Create Firefox Headless - Needs separate command-line arguments
    [arguments]         ${the_url}

    #${firefox options}=     Evaluate                sys.modules['selenium.webdriver'].firefox.webdriver.Options()    sys, selenium.webdriver
    ${firefox options}=     Evaluate                selenium.webdriver.firefox.webdriver.Options()

    Log To Console         ${\n}Firefox options...

    Call Method             ${firefox options}      add_argument    -headless

    Call Method             ${firefox options}      set_preference   profile.accept_untrusted_certs     ${True}

    Log To Console         ${\n}Firefox options done...

    Create Webdriver    Firefox    firefox_options=${firefox options}           # create the driver
    Set Window Size     ${HEADLESS_HEIGHT}   ${HEADLESS_WIDTH}                  # set window size

    ${DELAY}            Set Variable      1                                     # set delay to 1 sec
    Go To               ${the_url}                                              # go to login page


FirefoxDownload
    [Documentation]     Create Firefox Download - Needs special preferences - NOT WORKING - STILL SHOWS DOWNLOAD DIALOG
    [arguments]         ${the_url}

    ${download_dir}         Run Keyword    Get Download Directory

    ${firefox options}=     Evaluate    sys.modules['selenium.webdriver'].firefox.webdriver.Options()    sys, selenium.webdriver

    Call Method    ${firefox options}   set_preference    browser.download.folderList                   ${2}
    Call Method    ${firefox options}   set_preference    browser.download.manager.showWhenStarting     ${False}
    Call Method    ${firefox options}   set_preference    browser.download.dir                          ${download_dir}
    Call Method    ${firefox options}   set_preference    browser.download.useDownloadDir               ${True}
    Call Method    ${firefox options}   set_preference    browser.download.manager.useWindow            ${False}
    Call Method    ${firefox options}   set_preference    browser.download.manager.closeWhenDone        ${True}
    Call Method    ${firefox options}   set_preference    browser.download.manager.skipWinSecurityPolicyChecks      ${True}

    Call Method    ${firefox options}   set_preference    pref.downloads.disable_button.edit_actions    ${False}

    Call Method    ${firefox options}   set_preference    browser.helperApps.alwaysAsk.force          ${False}
    Call Method    ${firefox options}   set_preference    browser.helperApps.neverAsk.saveToDisk      application/csv
    Call Method    ${firefox options}   set_preference    browser.helperApps.neverAsk.saveToDisk      application/pdf
    Call Method    ${firefox options}   set_preference    browser.helperApps.neverAsk.saveToDisk      application/json
    Call Method    ${firefox options}   set_preference    browser.helperApps.neverAsk.saveToDisk      application/xls
    Call Method    ${firefox options}   set_preference    browser.helperApps.neverAsk.openFile        application/xls,application/excel,application/pdf,application/json

    Call Method    ${firefox options}   set_preference    pdfjs.disabled                              ${True}


    Create Webdriver    Firefox    firefox_options=${firefox_options}           # create the driver
    Set Window Size     ${HEADLESS_HEIGHT}   ${HEADLESS_WIDTH}                  # set window size

    Go To               ${the_url}                                              # go to login page


Firefox Plain
    [Documentation]     Firefox with plain profile - Experimental
    [arguments]         ${the_url}

    Log To Console         ${\n}Firefox With Plain Profile...

    open browser         ${the_url}    firefox


Firefox With Profile
    [Documentation]     Create Firefox with custom profile - Experimental
    [arguments]         ${the_url}

    Log To Console         ${\n}Firefox With Profile...

    ${download_dir}     Get Download Directory

    Log To Console         ${\n}Firefox dir = ${download_dir}...

    ${firefox options}     create_firefox_profile      ${download_dir}          # python code to create profile

    Log To Console         ${\n}Firefox options done...


    Create Webdriver    Firefox    options=${firefox options}                   # create the driver
    Set Window Size     ${HEADLESS_HEIGHT}   ${HEADLESS_WIDTH}                  # set window size

    ${DELAY}            Set Variable      1                                     # set delay to 1 sec
    Go To               ${the_url}                                              # go to login page


Edge Browser Options
    [Documentation]     Create Edge With Browser Options - Needs separate command-line arguments
    [arguments]         ${the_url}

    Log To Console      Setting Edge Parameters

#    ${EDGE_OPTIONS} =    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
   ${EDGE_OPTIONS}     Evaluate    selenium.webdriver.ChromeOptions()

    Call Method    ${EDGE_OPTIONS}      add_argument     --inprivate
    Call Method    ${EDGE_OPTIONS}      add_argument     --enable-chrome-browser-cloud-management

    SeleniumLibrary.Create Webdriver    Edge    options=${EDGE_OPTIONS}

    SeleniumLibrary.Go To               ${the_url}                                              # go to login page


Compare Lists
    [arguments]   ${list_1}  ${list_2}
    [Documentation]   Compare 2 lists - looking for differences only.

    ${len_list_1}   Get Length      ${list_1}
    ${len_list_2}   Get Length      ${list_2}

    @{status_list}          Create List                                         # save comparison status here
    @{length_list}          Create List  List Lengths are NOT Equal ${len_list_1} vs ${len_list_2}

    Return From Keyword If      ${len_list_1} != ${len_list_2}      ${length_list}


    ${index}    Set Variable    ${0}

    FOR  ${current_item}  IN  @{list_1}
        ${compare_item}     Get From List   ${list_2}  ${index}                 # get the value from list_2 at index
        ${are_equal}        Run Keyword And Return Status   Should Be Equal As Strings  ${current_item}  ${compare_item}

        # if the values are equal - add to list - failure
        Run Keyword If      ${are_equal}    Append To List  ${status_list}    ${current_item} = ${compare_item}
        ${index}            Evaluate   ${index} + 1                             # add 1 index
    END

    RETURN  ${status_list}


Get Request
    [arguments]         ${get_url}
    [Documentation]     Perform HTTP GET Request
    [Tags]              get

    Log                     Fetching URL : ${get_url}

    ${response}             RequestsLibrary.GET    ${get_url}                               # fetch the URL - get back response

    ${status_code}         Run Keyword And Return Status     Should Be Equal As Strings	${response.status_code}	    200
    Log    ${response.status_code}

#    ${status}               Status Should Be        OK    ${response}

    RETURN        ${status_code}


Post Request
    [arguments]         ${post_url}
    [Documentation]     Perform HTTP POST Request
    [Tags]              post

    Log                     Fetching URL : ${post_url}

    ${response}=            POST REQUEST    ${post_url}

    ${status}               Status Should Be     OK    ${response}


Get JSON Request
    [arguments]         ${get_url}    ${cookie_info_dict}
    [Documentation]     Perform HTTP GET Request Returning a JSON payload
    [Tags]              get    JSON

    Log                 Fetching URL : ${get_url}
    Log Dictionary      ${cookie_info_dict}

#    ${headers}              Create Dictionary   Accept=*/*    Content-Type=application/json-patch+json    Authorization=${bearer_auth}

    ${headers}              Create Dictionary   Accept=*/*    Content-Type=application/json-patch+json
#    ${cookies}              Create Dictionary   ${cookie_info}

    ${response}             RequestsLibrary.GET    ${get_url}    headers=${headers}   cookies=${cookie_info_dict}              # fetch the URL - get back response

    ${status_code}          Run Keyword And Return Status     Should Be Equal As Strings	${response.status_code}	    200
    Log                     ${response.status_code}

#    ${status}               Status Should Be        OK    ${response}

    RETURN        ${status_code}


Get Download Directory
    [Documentation]     Get the location of the Download Directory from Environment Variables - Windows

    ${home_drive}       Get Environment Variable    HOMEDRIVE    C:                             # get env var - default to C: if NOT found
    ${home_dir}         Get Environment Variable    Auto_Download                               # CUSTOM ENV Variable - in local user

    ${download_dir}     Join Path   ${home_drive}  ${home_dir}  Downloads                       # get the user Downloads location

    RETURN    ${download_dir}


Get All Web Element Attributes
    [arguments]         ${web_element_locator}

    [Documentation]     Get the location of the Download Directory from Environment Variables - Windows

    ${elements}    Get WebElements    ${web_element_locator}

    FOR    ${element}    IN    @{elements}
#        Log    ${element.get_attribute('innerHTML')}
        Log    ${element.get_attribute('outerHTML')}
    END


Create Page Checksum
    [arguments]         ${text_locator}  ${show_output}                           # locator for text area + debug flag
    [Documentation]     Create a checksum from text on a web page.

    # Get the on screen text from Locator
    ${page_text_list}   Run Keyword And Ignore Error    SeleniumLibrary.Get Text       ${text_locator}

    ${page_status}      Get From List   ${page_text_list}       0                  # get the 0 index from list - the status PASS | FAIL
    ${page_text}        Get From List   ${page_text_list}       1                  # get the 1 index from list - the page text

    ${current_url}      Get Location                                                # get the URL
    ${current_window}   Get Title                                                   # get the Page Title

    Log                 ${current_window}\n${current_url}\n\nPage Text :\n\n ${page_text}

    # if the Get Text was successful - compute page checksum
    IF    "${page_status}" == "PASS"
        ${page_checksum}    Run Keyword    create_checksum      ${page_text}  ${show_output}        # compute checksum in Python lib
    ELSE
        ${page_checksum}    Set Variable   No CheckSum Created                                      # no text - no checksum
    END

    RETURN        ${page_checksum}


Create Screen Shot
    [arguments]         ${delay_secs}                            # delay time seconds
    [Documentation]     Create a screen shot of current screen

    Sleep              ${delay_secs}
    Take Screenshot    ${SCREENSHOT_DIRECTORY}                  # take a screen shot - send to Global Var Dir


Check Values In List
    [arguments]         ${orig_list}    ${in_string}                            #
    [Documentation]     check that list values are in string

    ${status_list}      Create List

    FOR    ${curr_item}    IN    @{orig_list}

        ${contains}    Run Keyword And Return Status    Should Contain    ${in_string}    ${curr_item}      ignore_case=True

        # if the test failed - add it to the list
        Run Keyword If      not ${contains}       Append To List  ${status_list}    ${TWO_SPACES}Term : '${curr_item}' NOT In : ${in_string}                  # add string to list if NOT found

    END

    RETURN    ${status_list}


Check Variable Type
    [Arguments]    ${object}
    [Documentation]    Checks if the ${object } is INTEGER, NUMBER or STRING

    Return From Keyword If      not "${object}"    NONE

    ${python_type}              get_python_type      ${object}               # use Python Lib to detect the datatype

    RETURN    ${python_type}

#    ${result}    ${value}    Run Keyword And Ignore Error    Convert To Number    ${object}
#
#    ${isnumber}    Run Keyword And Return Status    Should Be Equal As Strings    ${object}    ${value}
#
#    ${python_type}      Evaluate    type(${value})
#
#    ${result}    ${value}    Run Keyword And Ignore Error    Convert To Integer    ${object}
#
#    ${isinteger}    Run Keyword And Return Status    Should Be Equal As Strings    ${object}    ${value}
#
#    Return From Keyword If      ${isnumber}     NUMBER
#    Return From Keyword If      ${isinteger}    INTEGER
#    Return From Keyword         STRING


Find IFrame On Page
    [Documentation]    Find the IFrame element on the page

    ${iframe_locator}       Set Variable        path=//iframe[@class='IFRAME NOT FOUND']            # initialize to BAD name
    ${element_List}         Get Webelements     xpath=//iframe                                      # locate all IFrames on the page


    FOR    ${item}     IN      @{element_List}                                                      # There should be ONLY 1 IFrame
        ${class_name}       Set Variable  ${item.get_attribute('class')}

        #Log to Console      IFrame : ${class_name}
        ${iframe_locator}   Set Variable  xpath=//iframe[@class='${class_name}']

        #Log To Console     ${iframe_locator}
        BREAK

    END

    RETURN    ${iframe_locator}


Get Memory Stats
    [Documentation]    Run API Call to get server Stats

    Log Dictionary    ${COOKIES_DICT}

    ${cookie_len}       Get Length    ${COOKIES_DICT}

    IF    ${cookie_len} > 0
#        ${cookie_value}     Get From Dictionary    ${COOKIES_DICT}    _xsrf

        ${api_url}          Get API Hub
        #${cookie_dict}      Create Dictionary        _xsrf=${cookie_value}

        ${status}    Run Keyword And Continue On Failure    Get JSON Request    ${api_url}      ${COOKIES_DICT}

    END


Get API Hub
    [Documentation]    Get the name of the API hub on the current server

    ${hub_name}        Set Variable    hub-k8s.
    #${hub_name}        Set Variable    api.
    ${url_path}        Set Variable    user/${USER}/api/metrics/v1

#    @{words_list}      Split String	   ${SERVER}	.
#
#    ${new_server_1}    Get From List    ${words_list}   1
#    ${new_server_2}    Get From List    ${words_list}   2
#    ${new_server}      Set Variable     ${hub_name}${new_server_1}.${new_server_2}
    ${new_server}      Set Variable     ${hub_name}${SERVER}

    ${api_url}         Set Variable    ${PROTOCOL}://${new_server}/${url_path}                      # get the current url on server

    Log                 API : ${api_url}

    RETURN      ${api_url}


Get Memory Stats OLD
    [Documentation]    Run API Call to get server Stats


    @{all_windows}    SeleniumLibrary.Get Window Titles                     # find all window titles
    ${main_window}    Get From List    ${all_windows}     0                 # get the original window title

    ${hub_name}        Set Variable    hub.
    #${hub_name}        Set Variable    api.
    ${url_path}        Set Variable    user/${USER}/api/metrics/v1

    @{words_list}      Split String	   ${SERVER}	.

    ${new_server_1}    Get From List    ${words_list}   1
    ${new_server_2}    Get From List    ${words_list}   2
    ${new_server}      Set Variable     ${hub_name}${new_server_1}.${new_server_2}

    ${api_url}         Set Variable    ${PROTOCOL}://${new_server}/${url_path}                      # get the current url on server

    Log                 API : ${api_url}


    ${browser_status}   New Browser Tab     ${api_url}                                                                  # open new TAB with api URL

    Sleep    5s

    ${json_string_raw}      SeleniumLibrary.Get Text    ${MAIN_BROWSER_WINDOW}                  # get the JSON from the page

    @{all_window_handles}       SeleniumLibrary.Get Window Handles                                  # find all window handles

    ${last_window}              Get From List    ${all_window_handles}     -1                       # get the last window handle

    IF    ${browser_status} == ${True}

        ${the_type}             get_python_type     ${json_string_raw}
        log     Type = ${the_type}

        ${json_source}               Replace String	 ${json_string_raw}	    true	"True"
     #   ${json_source}              Convert To Dictionary    ${str}                             # convert JSON string to a dict
    #    @{words} 	Split String	${str}	 ,${SPACE}
    #    @{words2} 	Split String	${str}	 :${SPACE}

        #${json_source}              Evaluate    json.loads('''${str}''') json
        #${json_source}              Evaluate    json.loads(${str}) json


        SeleniumLibrary.Switch Window       ${main_window}                                              # select the original window

        Close Browser Tab                   ${last_window}

        SeleniumLibrary.Switch Window       ${main_window}                                              # select the original window

        ${csv_line}     create_csv_string   ${json_source}

    ELSE

        SeleniumLibrary.Switch Window       ${main_window}                                              # select the original window

        Close Browser Tab                   ${last_window}

        SeleniumLibrary.Switch Window       ${main_window}                                              # select the original window

        Fail    Failure Opening URL : ${api_url}\n\n${json_string_raw}
    END

    RETURN      ${csv_line}


Run Program Get Ouput
    [Arguments]        ${program_name}    ${cmd_args}
    [Documentation]    Run a given program and return the screen output

    #${result} =     Run Process     python    -c    print('Hello, world!')
    ${result}      Run Process     ${program_name}    ${cmd_args}

    Log    ${result}
    Log    ${result.stdout}