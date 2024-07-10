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

# Quantamatics URL info

${SERVER}           quantamatics.com                                            # server where Quantamatics is running - over-ride with cmd-line value
${ACTIVE_MENU}      research/my-files

${PROTOCOL}         https                                                       # default protocol is secure
${LOGIN_URL}        ${PROTOCOL}://${SERVER}/login
${WELCOME_URL}      ${PROTOCOL}://${SERVER}/${ACTIVE_MENU}                      # initial landing url - active menu value
${ERROR_URL}        ${PROTOCOL}://${SERVER}/
${DEFAULT_TITLE}    Sign In | Quantamatics                                      # partial match on page title version

${EMAIL_DOMAIN}     @mailinator.com                                             # test email domain

${ALT_FIREFOX_PROFILE}       Profiles${PATH_SEPERATOR}FireFoxAutomationUserProfile   # location of special FF profile - download tests
${DATA_DIRECTORY}           ..${PATH_SEPERATOR}data${PATH_SEPERATOR}                 # location of data files


*** Keywords ***


Test All Menus
    [Documentation]     Test the Left-Side Menus

    # List of terms to search on by menu name

    @{research_term_list}       Create List             Name    Last Modified    File size
    @{apps_term_list}           Create List             Apps        Facteus
    @{excel_term_list}          Create List             Name        Excel Library      Welcome to the      Getting Started      Download & Install   Start Using the Plug-in
    @{my_assets_term_list}      Create List             My Assets
    @{organization_term_list}   Create List             Organization Name          CRM Customer ID      CRM Customer Link               Comments
    @{user_term_list}           Create List             First Name      Last Name  Email        Expiration Date     Organization        Organization Role
    @{all_assets_term_list}     Create List             All Assets      Name      Filename   Author    Type     Created      Last Modified
    @{settings_term_list}       Create List             First Name      Last Name  Email        Organization        Expiration Date     Organization Role   Enable/Disable Assets   Assets
    @{help_term_list}           Create List             Need Help?      Documentation           visit the docs      Contact Us          email support

    @{copyright_term_list}      Create List             Quantamatics    ${COPYRIGHT_INFO}
    @{element_list}             Create List             ${MENU_HIDE_BUTTON}

    &{menu_dict_iframe}     Create Dictionary       ${MENU_EXCEL_LIBRARY}=${excel_term_list}    ${MENU_RESEARCH}=${research_term_list}
    &{menu_dict_main}       Create Dictionary       ${MENU_APPS}=${apps_term_list}    ${MENU_MY_ASSETS}=${my_assets_term_list}    ${MENU_ORGANIZATIONS}=${organization_term_list}     ${MENU_USER_ACCOUNTS}=${user_term_list}   All Assets=${all_assets_term_list}   ${MENU_SETTINGS}=${settings_term_list}  ${MENU_NEED_HELP}=${help_term_list}


    ${full_test_name}       Set Variable    Test All Menus - Menu Bar
    Run Keyword And Continue on Failure     Verify On Screen Text    ${full_test_name}       @{copyright_term_list}     # look for these menu terms on page

    Run Keyword And Continue on Failure     Toggle Buttons      "Test All Menus - Hide Menu"     @{element_list}          # click the sorting buttons


    # Test The IFrame Menus here -  Excel Library | Research

     FOR    ${menu_key}    IN    @{menu_dict_iframe.keys()}

        ${menu_found}          Run Keyword     Select Menu  ${menu_key}                                                 # Select the menu - left-side of screen

        Continue For Loop If   ${menu_found} == ${False}                                                                # if the menu was not found - continue

        ${iframe_name}          Run Keyword    Find IFrame On Page                                                      # find the name of the IFrame

        SeleniumLibrary.Select Frame        ${iframe_name}                                                              # Select the main iframe content

        @{terms}=                           Get From Dictionary    ${menu_dict_iframe}    ${menu_key}                   # get the search terms

        ${full_test_name}                   Set Variable    Test All Menus - ${menu_key}                                # create the test name

        Run Keyword And Continue on Failure     Verify On Screen Text    ${full_test_name}       @{terms}               # look for these terms on page

        SeleniumLibrary.Unselect Frame                                                                                  # Unselect the main iframe

     END

    # Test The Flat Menus here - Apps | My Assets | Organizations | User Accounts |  All Assets | Settings | Need Help

     FOR    ${menu_key}    IN  @{menu_dict_main.keys()}

        ${menu_found}          Run Keyword     Select Menu   ${menu_key}                                                # Select the menu - left-side of screen

        Continue For Loop If   ${menu_found} == ${False}                                                                # if the menu was not found - continue

        # Look for the element "No Assets Were Found" on screen
        ${no_assets_status}      Run Keyword And Return Status        Element Should Be Visible    ${NO_ASSETS_LOCATOR}

        # Check to see if there are NO Assets - Cannot continue
        Continue For Loop If   ${no_assets_status} == ${True}

        @{terms}=              Get From Dictionary    ${menu_dict_main}    ${menu_key}                                 # get the search terms

        ${full_test_name}      Set Variable    Test All Menus - ${menu_key}                                            # create the test name

        Run Keyword And Continue on Failure     Verify On Screen Text       ${full_test_name}     @{terms}              # look for these terms on page

     END


Download Excel Plugin
    [Documentation]     Click on [Get Excel Plug-in] - validate that installer exists in User Download Directory

    Set Tags                Download Excel Plugin                                                    # set test environment for test case

    IF   ${Use_Alt_Profile} or '${BROWSER}' == "Edge"
        ${file_name}=        Set Variable    setup.msi                                          # Edge / FireFox - the installer file
    ELSE
        ${file_name}=        Set Variable    Unconfirmed*.crdownload                            # Chrome - Gets prompted for harmful app - the installer file
    END

    Remove Files From Download Dir      ${file_name}                                            # delete any previous version of installer

    SeleniumLibrary.Click Element       ${EXCEL_DOWNLOAD_LINK}                                  # click the menu choice - Get Excel Plug-in

#    Create Screen Shot       3s                                                                 # take a screen shot of download

    Sleep               30s                                                                     # wait for file to download

    ${download_dir}     Run Keyword    Get Download Directory

    ${install_file}     Join Path   ${download_dir}  ${file_name}                               # create the path to installer

    Run Keyword And Continue on Failure     Check File Exists   ${install_file}     ${True}     # validate that installer is in Downloads


Organization Page Search
    [Documentation]     Perform a search on the Organization Page

    Set Tags                Organization Page                                    # Add tag

    @{organization_term_list}   Create List     Facteus   Po    De      xyz
    ${row_locator}=             set variable    //tbody/tr
    ${menu_choice}              Set Variable    ${MENU_ORGANIZATIONS}

    ${menu_found}          Run Keyword   Select Menu      ${menu_choice}                         # Select the menu - left-side of screen

    IF   ${menu_found} == ${False}                                                               # if the menu was not found - return from keyword
        Log     User ${USER} Does NOT have Acess to Menu : ${menu_choice}
        Return From Keyword
    END

    Run Keyword and Continue on Failure    Search Field          ${ORGANIZATION_SEARCH_FIELD}   ${organization_term_list}  ${row_locator}          # perform searches on terms


Organization Page Operations
    [Documentation]     Perform operations on the Organization Page

    Set Tags            Organization Page                                    # Add tag

    @{organization_term_list}       Create List    Create an Organization     Organization Name   CRM Customer ID         CRM Customer ID Link    Comments
    @{element_sort_list}            Create List    ${ORGANIZATION_NAME_BUTTON}       ${ORGANIZATION_CUSTOMER_ID_BUTTON}    ${ORGANIZATION_CUSTOMER_LINK_BUTTON}        ${ORGANIZATION_COMMENTS_BUTTON}

    ${menu_choice}         Set Variable    ${MENU_ORGANIZATIONS}

    ${menu_found}          Run Keyword   Select Menu      ${menu_choice}                         # Select the menu - left-side of screen

    IF   ${menu_found} == ${False}                                                               # if the menu was not found - return from keyword
        Log     User ${USER} Does NOT have Acess to Menu : ${menu_choice}
        Return From Keyword
    END

    Run Keyword And Continue on Failure     Toggle Buttons      "Organization Page - Toggle Sorts"     @{element_sort_list}              # click the sorting buttons

    # Click [Create] Button
    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${ORGANIZATION_CREATE_BUTTON}             # click the [Create] element
    Sleep   5s

    Run Keyword And Continue on Failure     Verify On Screen Text       "Organization Create Page"     @{organization_term_list}    # validate screen text

    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${CREATE_DIALOG_CANCEL_BUTTON}            # click the [Cancel] element
    Sleep   5s


User Account Page Search
    [Documentation]     Perform a search on the User Account Page
    Set Tags            User Account Page                                     # Add tag

    @{user_page_term_list}   Create List     Facteus   Steve    Br   Dav
    ${row_locator}=          Set Variable    //tbody/tr
    ${menu_choice}           Set Variable    ${MENU_USER_ACCOUNTS}

    ${menu_found}          Run Keyword   Select Menu      ${menu_choice}                         # Select the menu - left-side of screen

    IF   ${menu_found} == ${False}                                                               # if the menu was not found - return from keyword
        Log     User ${USER} Does NOT have Acess to Menu : ${menu_choice}
        Return From Keyword
    END


    Run Keyword and Continue on Failure    Search Field             ${USER_ACCOUNT_SEARCH_FIELD}   ${user_page_term_list}  ${row_locator}             # perform searches on terms


All Assets Page Search
    [Documentation]     Perform a search on the All Assets Page
    Set Tags            All Assets Page                                    # Add tag

    @{asset_page_term_list}     Create List    Facteus   ipynb      Product     Function
    @{edit_term_list}           Create List    Name      Enabled Orgs      Description     Enabled Users    Created    Last Modified    Author     Owner Org Name

    IF  '${BROWSER}' == "Firefox"
        ${row_locator}             Set Variable   xpath=//td[1]                # for Firefox - Click on 1st TD element
    ELSE
        ${row_locator}             Set Variable   //tbody/tr[1]
    END

    ${menu_choice}              Set Variable   All Assets
    @{element_sort_list}        Create List    ${ALL_ASSETS_NAME_BUTTON}       ${ALL_ASSETS_FILENAME_BUTTON}    ${ALL_ASSETS_AUTHOR_BUTTON}        ${ALL_ASSETS_TYPE_BUTTON}    ${ALL_ASSETS_CREATED_BUTTON}     ${ALL_ASSETS_LAST_MODIFIED_BUTTON}

    ${menu_found}          Run Keyword   Select Menu      ${menu_choice}                         # Select the menu - left-side of screen

    IF   ${menu_found} == ${False}                                                               # if the menu was not found - return from keyword
        Log     User ${USER} Does NOT have Acess to Menu : ${menu_choice}
        Return From Keyword
    END

    # Look for the element "No Assets Were Found" on screen
    ${no_assets_status}      Run Keyword And Return Status        Element Should Be Visible    ${NO_ASSETS_LOCATOR}

    # Check to see if there are NO Assets - Cannot continue
    IF  ${no_assets_status} == ${True}
        Log To Console          ${\n}NO Assets Found - Cannot Continue.${\n}
        Return From Keyword
    END


    Run Keyword And Continue on Failure    Toggle Buttons      "All Assets Page - Toggle Sorts"     @{element_sort_list}              # click the sorting buttons

    # Click on first Asset - go to Edit mode
    Run Keyword And Ignore Error    SeleniumLibrary.Scroll Element Into View    ${row_locator}

    ${click_status}    Run Keyword And Return Status    SeleniumLibrary.Click Element     ${row_locator}                # click the 1st row - to edit user
    Sleep   5s

    IF   ${click_status} == ${False}                                                                                    # if the row could NOT be clicked - return from keyword
        Fail     All Assets Page Search : ${BROWSER} : Cannot Click on 1st Record : User ${USER}
        Return From Keyword
    END

    Run Keyword And Continue on Failure     Verify On Screen Text       "All Asset Edit Page"     @{edit_term_list}             # validate screen text

    # click the [All Assets] - to return to All Assets page

    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${ALL_ASSETS_BACK_LINK}
    Sleep   5s

    Run Keyword and Continue on Failure    Search Field        ${ALL_ASSETS_SEARCH_FIELD}   ${asset_page_term_list}  ${row_locator}             # perform searches on terms

    Select Home Icon


Research Page Operations
    [Documentation]     Perform operations on the Research Page

    Set Tags            Research Page   User Restart Server                                   # Add tags

    @{research_term_list}       Create List             Research    New      Name    Last Modified       File size
    @{element_list}             Create List             ${SORT_NAME_BUTTON}    ${SORT_LAST_MODIFIED_BUTTON}        ${SORT_FILE_SIZE_BUTTON}
    @{server_list}              Create List             ${REFRESH_SERVER_BUTTON}


    Select Menu                       ${MENU_RESEARCH}                  # Select the menu - left-side of screen

    ${iframe_name}          Run Keyword    Find IFrame On Page          # find the name of the IFrame

    SeleniumLibrary.Select Frame      ${iframe_name}                    # Select the main iframe content

#    ${upload_status}     Run Keyword And Return Status     SeleniumLibrary.Click Element       ${FILE_UPLOAD_BUTTON}           # click the file upload [^] button - File Dialog will open
#    Sleep  4s
#    @{all_window_handles}       SeleniumLibrary.Get Window Handles                                  # find all window handles
#    @{all_window_titles}        SeleniumLibrary.Get Window Titles                                  # find all window handles

#  ** Sending the Keyboard Cmds - causes system to be unstable after run - Keyboard & mouse
#    Faker_Data_Generator.Custom Key Press       Alt+F4                                                          # send keys to Close File Dialog

    Run Keyword And Continue on Failure     Toggle Buttons      "Research Page - Elements"     @{element_list}          # click the sorting buttons
    Run Keyword And Continue on Failure     Toggle Buttons      "Research Page - Buttons"      @{server_list}           # click the refresh button

    Run Keyword And Continue on Failure     SeleniumLibrary.Click Button   ${RESTART_SERVER_BUTTON}                     # click the [(|)] button
    Sleep  2s

    ${server_restart_status}         Run Keyword And Return Status     SeleniumLibrary.Click Button   ${DIALOG_RESTART_SERVER_BUTTON}              # On Dialog - click the [Restart] button
    Sleep  10s                                                                                                          # LONG WAIT for server to restart

    # wait for the restart message on screen
    ${restart_status}    Run Keyword And Return Status       Wait Until Element Is Visible    ${RESTART_HEADER_LOCATOR}      30s

    # Look for the Info Icon on screen
    ${info_status}      Run Keyword And Return Status        Element Should Be Visible    ${RESTART_INFO_LOCATOR}

    # if (Info) icon on screen - hover mouse over element while server restarts

    IF    ${info_status}
        ${hover_status}    Run Keyword And Return Status      Mouse Over          ${RESTART_INFO_LOCATOR}
    END


    Sleep    20s

    Run Keyword And Continue on Failure     Verify On Screen Text       "Research Page"     @{research_term_list}       # validate screen text

    SeleniumLibrary.Unselect Frame                                      # Unselect the main iframe


Excel Library Page Operations
    [Documentation]     Perform operations on the Excel Library Page
    Set Tags            Excel Library Page                                    # Add tag

    @{excel_term_list}          Create List             Excel Library    Welcome to the Excel Library      Name    Last Modified       File size
    @{element_list}             Create List             ${SORT_NAME_BUTTON}    ${SORT_LAST_MODIFIED_BUTTON}        ${SORT_FILE_SIZE_BUTTON}
    @{server_list}              Create List             ${REFRESH_SERVER_BUTTON}


    Select Menu                     ${MENU_EXCEL_LIBRARY}                 # Select the menu - left-side of screen

    ${iframe_name}          Run Keyword    Find IFrame On Page            # find the name of the IFrame

    SeleniumLibrary.Select Frame    ${iframe_name}                        # Select the main iframe content

    Run Keyword And Continue on Failure     Toggle Buttons      "Excel Page - Elements"     @{element_list}             # click the sorting buttons
    Run Keyword And Continue on Failure     Toggle Buttons      "Excel Page - Buttons"      @{server_list}              # click the refresh button

    Run Keyword And Continue on Failure     SeleniumLibrary.Click Button   ${RESTART_SERVER_BUTTON}                     # click the [(|)] button
    Sleep  2s

    Run Keyword And Continue on Failure     SeleniumLibrary.Click Button   ${DIALOG_RESTART_SERVER_BUTTON}              # On Dialog - click the [Restart] button

    Sleep  60s                                                                                                          # LONG WAIT for server to restart
    Run Keyword And Continue on Failure     SeleniumLibrary.Click Button   ${REFRESH_SERVER_BUTTON}                     # click the [(|)] button


    Run Keyword And Continue on Failure     Verify On Screen Text       "Excel Page"     @{excel_term_list}             # validate screen text

    SeleniumLibrary.Unselect Frame                                       # Unselect the main iframe


Check External Links TOS
    [Documentation]     Perform operations on External Links
    Set Tags            TOS                                       # Add tags

    #${main_window}      Set Variable    My Account | Quantamatics
    ${main_window}      SeleniumLibrary.Get Title
    ${tos_url}          Set Variable    ${PROTOCOL}://${SERVER}/quantamatics-terms-of-use-agreement.pdf

# Check on The Terms of Service document on Server via GET Request - expecting a response of OK

    ${fetch_status}     Run Keyword And Return Status     Get Request         ${tos_url}                 # run GET request to fetch TOS PDF file

    IF   ${fetch_status} == ${False}
        Fail         URL ${tos_url} NOT Found - Failing Test - Returning...
        RETURN      ${False}                                                                        # element NOT visible return False
    END


# Open the TOS URL In a NEW Browser TAB


    New Browser Tab     ${tos_url}                                                                      # open the TOS_URL in a new browser tab

    @{all_windows}      SeleniumLibrary.Get Window Titles                                               # find all window titles & handles
    @{win_handles}      SeleniumLibrary.Get Window Handles

    List Should Contain Value    ${all_windows}     undefined                                           # PDF file will have Page Title = undefined

    ${new_window}       Get From List       ${win_handles}    -1                                        # get LAST window handle from list - should be NEW tab

    Close Browser Tab   ${new_window}                                                                   # close the new TOS Tab

    ${status}           SeleniumLibrary.Switch Window   ${main_window}                                  # select the main window


Check External Links Privacy Policy
    [Documentation]     Perform operations on External Links - Privacy Policy
    Set Tags            Privacy Policy                                       # Add tags

# Open the Privacy Policy url via clicking on Link - Opens a new Tab in browser
    ${policy_text_locator}      Set Variable    //div[@id='block-01d9cf00fe9195a06d51']//div[@class='sqs-block-content']

    ${status}           Run Keyword    SeleniumLibrary.Click Element     ${PRIVACY_POLICY}              # click the privacy policy element - main nav window - bottom
    Sleep               7s

    @{all_windows}      SeleniumLibrary.Get Window Titles                                               # find all window titles

    ${main_window}      Get From List     ${all_windows}   0                                            # Get the main window (original)

    List Should Contain Value    ${all_windows}     ${PRIVACY_POLICY_TITLE}                             # validate Window Title

    ${status}           Run Keyword And Return Status    SeleniumLibrary.Switch Window   ${PRIVACY_POLICY_TITLE}                                  # select the main window

    ${page_text_list}   Run Keyword And Ignore Error    SeleniumLibrary.Get Text       ${policy_text_locator}
    ${privacy_text}     Get From List                   ${page_text_list}      -1                       # get the date of th privacy policy

    Log                 Privacy Policy Text : ${privacy_text}

    ${status}           Run Keyword And Return Status    Close Browser Tab   ${PRIVACY_POLICY_TITLE}    # close the new Privacy Policy Tab

    Run Keyword And Continue On Failure    Should Be True	${status}        Expecting Close Browser Tab To Be True - Value : ${Status}

    ${status}           Run Keyword And Return Status    SeleniumLibrary.Switch Window   ${main_window}                                  # select the main window

    Run Keyword And Continue On Failure    Should Be True	${status}        External Links Privacy Policy - Expecting Switch Window To Be True - Value : ${Status}


Check External Links Visit The Docs
    [Documentation]     Perform operations on External Links - Visit The Docs
    Set Tags            Visit The Docs                                    # Add tags

#    Check the Need Help Link - Visit The Docs

    Select Menu         ${MENU_NEED_HELP}                                                               # Click the Menu Link

    ${status}           Run Keyword    SeleniumLibrary.Click Element     ${VISIT_THE_DOCS}              # click the new Visit The Docs element
    Sleep   5s

    @{all_windows}          SeleniumLibrary.Get Window Titles                                               # find all window titles
    ${main_window_title}    Get From List    ${all_windows}     0

    List Should Contain Value    ${all_windows}     ${QUANTAMATICS_DOCUMENTATION_TITLE}                 # validate window title

    Close Browser Tab   ${QUANTAMATICS_DOCUMENTATION_TITLE}                                             # close the Quantamatics Documentation Tab

    #${status}           SeleniumLibrary.Switch Window   Support                                         # select the main window
    ${status}           SeleniumLibrary.Switch Window   ${main_window_title}                             # select the main window


Check External Links Contact Us
    [Documentation]     Perform operations on External Links - Contact Us
    Set Tags            Contact Us                                    # Add tags

    @{contact_term_list}        Create List             Documentation       visit the docs      Contact Us      email support


#    Check the Need Help Link - Visit The Docs

    Select Menu         ${MENU_NEED_HELP}                                                                  # Click the Menu Link

    Run Keyword And Continue on Failure     Verify On Screen Text       "Need Help - Contact Us"     @{contact_term_list}         # validate screen text

    Run Keyword And Continue On Failure     Element Should Be Visible	${EMAIL_SUPPORT}	   Email Support Link Expected to be Visible : ${EMAIL_SUPPORT}
    Run Keyword And Continue On Failure     Element Should Be Visible	${VISIT_THE_DOCS}	   Visit The Docs Link Expected to be Visible : ${VISIT_THE_DOCS}


Check External Links Release Notes
    [Documentation]     Perform operations on Release Notes
    Set Tags            Release Notes                                       # Add tags

    @{all_windows}    SeleniumLibrary.Get Window Titles                     # find all window titles
    ${main_window}    Get From List    ${all_windows}     0                 # get the original window title

    ${release_notes_title}      Set Variable    Release Notes - Quantamatics Documentation

    ${server_prefix}=    Fetch From Left    ${SERVER}    .              # get the prefix from the server variable

    IF    '${server_prefix}' == 'beta'
        ${new_url}   Set Variable   docs.quantamatics.com               # special case for production (beta)
    ELSE
        ${new_url}   Set Variable    docs.${SERVER}                     # all other server environments
    END

    Log    ${new_url}

    ${release_notes_url}        Set Variable    ${PROTOCOL}://${new_url}/index.html                                     # Top-Level docs page

    # All of the Menu Links & search terms for Docs Page

    @{research_term_list}                Create List            Research    Features    Juypter Notebooks
    @{research_createapi_term_list}      Create List            Create API    create a new function asset    update an existing function asset

    @{excel_plugin_term_list}            Create List            Excel Plug-in    Prerequisites    Download and Install    Plug-in Updates
    @{excel_using_plugin_term_list}      Create List            Start Using the Plug-in    Open the Excel desktop application    Output Controls    Function Import
    @{excel_plugin_functions_term_list}  Create List            Plug-in Functions    Get Panel Daily    Get Panel FQ    Get KPIs

    @{excel_library_term_list}           Create List            Excel Library    Each workbook template

    @{python_sdk_api_term_list}          Create List            Python SDK & API    Error Codes    Authentication    Getting Function Metadata
    @{python_session_term_list}          Create List            Session    Parameters    Methods    Return Values    Exceptions
    @{python_gateway_term_list}          Create List            API Gateway    Constructor    Return Values    Exceptions
    @{python_security_term_list}         Create List            Security Master    Company    Instrument    Universe
    @{python_fundamentals_term_list}     Create List            Fundamentals    Calendar Periods    KPI
    @{python_panels_term_list}           Create List            Panels    Parameters    Methods    ticker value

    @{asset_management_term_list}        Create List            Asset Management    Features    All Assets    My Assets
    @{asset_all_term_list}               Create List            All Assets    Prerequisites    View Details    Enable an Asset
    @{asset_my_term_list}                Create List            My Assets    A function asset can be deleted

    @{user_admin_term_list}              Create List            User Administration    Prerequisites    Assets    Settings

    @{release_notes_term_list}           Create List            Release Notes   API    SDK    Copyright


    # The Left-side Menus AND Submenus

    &{menu_dict_main}           Create Dictionary      ${MENU_RESEARCH}=${research_term_list}   Create API=${research_createapi_term_list}
                                                 ...   Excel Plug-in=${excel_plugin_term_list}    Using the Plug-in=${excel_using_plugin_term_list}  Plug-in Functions=${excel_plugin_functions_term_list}
                                                 ...   ${MENU_EXCEL_LIBRARY}=${excel_library_term_list}
                                                 ...   Python SDK & API=${python_sdk_api_term_list}  Session=${python_session_term_list}    API Gateway=${python_gateway_term_list}  Security Master=${python_security_term_list}  Fundamentals=${python_fundamentals_term_list}   Panels=${python_panels_term_list}
                                                 ...   Asset Management=${asset_management_term_list}  All Assets=${asset_all_term_list}    ${MENU_MY_ASSETS}=${asset_my_term_list}
                                                 ...   User Administration=${user_admin_term_list}
                                                 ...   Release Notes=${release_notes_term_list}


# Check on The Release Notes on Server via GET Request - expecting a status code 200

    ${fetch_status}     Run Keyword      Get Request         ${release_notes_url}                                       # run GET request to fetch release notes file

    IF   ${fetch_status} == ${False}
        Fail        URL ${release_notes_url} NOT Found - Failing Test - Returning...
        RETURN      ${False}                                                                                            # URL NOT Found -  return False
    END

# Open the Release Notes URL In a NEW Browser TAB


    New Browser Tab     ${release_notes_url}                                                                            # open the TOS_URL in a new browser tab

# Check the Menu Links for Text Terms

     FOR    ${link_key}    IN  @{menu_dict_main.keys()}

        ${element_visible}     BuiltIn.Run Keyword And Return Status    SeleniumLibrary.Element Should Be Visible   link=${link_key}

        Continue For Loop If   ${element_visible} == ${False}                                                           # if the menu was not found - continue

        ${menu_found}          Run Keyword     SeleniumLibrary.Click Link    link=${link_key}                           # Select the menu - left-side of screen

        Continue For Loop If   ${menu_found} == ${False}                                                                # if the menu was not found - continue

        ${current_url}         SeleniumLibrary.Get Location
        ${current_title}       SeleniumLibrary.Get Title

        Run Keyword And Continue on Failure     Should Contain     ${current_title}    ${link_key}                      # check the Page title vs Link Key

        @{terms}=              Get From Dictionary    ${menu_dict_main}    ${link_key}                                  # get the search terms

        ${full_test_name}      Set Variable    Release Notes - Link ${link_key}                                         # create the test name

        Run Keyword And Continue on Failure     Verify On Screen Text       ${full_test_name}     @{terms}              # look for these terms on page

     END


    @{all_windows}      SeleniumLibrary.Get Window Titles                                                               # find all window titles & handles
    @{win_handles}      SeleniumLibrary.Get Window Handles


    ${new_window}       Get From List       ${win_handles}    -1                                                        # get LAST window handle from list - should be NEW tab

    Close Browser Tab   ${new_window}                                                                                   # close the new Release Notes Tab

    ${status}           SeleniumLibrary.Switch Window   ${main_window}                                                  # select the main window


Settings Page Operations
    [Documentation]     Perform operations on the Settings Page
    Set Tags            Settings Page                                    # Add tag

    @{edit_term_list}       Create List             User Account        First Name     Last Name   Email    Expiration Date    Organization     Organization Role
    @{assets_term_list}     Create List             Assets              Name            All Users
    @{add_term_list}        Create List             Create a User Account               First Name          Last Name               Email        Expiration Date     Organization Role
    @{organization_term_list}        Create List    Create an Organzation               Organization Name   CRM Customer ID         CRM Customer ID Link    Comments

    @{element_list}         Create List             ${SETTINGS_MANAGE_ASSETS_NAME_BUTTON}
    @{element_sort_list}    Create List             ${SETTINGS_FIRST_NAME_BUTTON}       ${SETTINGS_LAST_NAME_BUTTON}    ${SETTINGS_EMAIL_BUTTON}        ${SETTINGS_EXPIRATION_BUTTON}       ${SETTINGS_ORGANIZATION_BUTTON}

    @{settings_term_list}   Create List             Facteus   Po    De      xyz
    ${row_locator}=         set variable            (//tr)[2]


    ${menu_choice}         Set Variable    ${MENU_SETTINGS}

    ${menu_found}          Run Keyword   Select Menu      ${menu_choice}                         # Select the menu - left-side of screen

    IF   ${menu_found} == ${False}                                                               # if the menu was not found - return from keyword
        Log     User ${USER} Does NOT have Acess to Menu : ${menu_choice}
        Return From Keyword
    END

    Run Keyword And Continue on Failure     Toggle Buttons      "Settings Page - User Accounts - Toggle Sorts"     @{element_sort_list}              # click the sorting buttons

    # Click [+Add] Button
    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${SETTINGS_ADD_BUTTON}       # click the [+Add] element
    Sleep   5s

    Run Keyword And Continue on Failure     Verify On Screen Text       "Asset Add Page"     @{add_term_list}         # validate screen text

    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${ADD_DIALOG_CANCEL_BUTTON}  # click the [Cancel] element
    Sleep   5s


    # Click [Enable/Disable Assets] Button
    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${SETTINGS_MANAGE_ASSETS_BUTTON}          # click the [Enable/Disable Assets] element
    Sleep   5s

    Run Keyword And Continue on Failure     Verify On Screen Text       "Enable/Disable Assets"     @{assets_term_list}             # validate screen text

    Run Keyword And Continue on Failure     Toggle Buttons      "Settings Page - Manage Assets - Name Sort"     @{element_list}     # click the sorting buttons

    run keyword and continue on failure     Search Field          ${SETTINGS_SEARCH_FIELD}   ${settings_term_list}  ${row_locator}          # perform searches on terms

    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${MANAGE_DIALOG_CANCEL_BUTTON}            # click the [Cancel] element
    Sleep   5s

    IF  '${BROWSER}' == "Firefox"
        ${first_row_locator}=             Set Variable   xpath=//body[1]/div[1]/main[1]/section[2]/table[1]/tbody[1]/tr[1]/td[1]               # for Firefox - Click on 1st TD element
    ELSE
        ${first_row_locator}=             Set Variable   xpath=//body[1]/div[1]/main[1]/section[2]/table[1]/tbody[1]/tr[1]
    END

    # Click on first user - go to Edit mode
    Run Keyword And Ignore Error    SeleniumLibrary.Scroll Element Into View    ${first_row_locator}

    ${click_status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${first_row_locator}    # click the 1st row - to edit user
    Sleep   5s

    IF   ${click_status} == ${False}                                                                                    # if the row could NOT be clicked - return from keyword
        Fail    Settings Page Operations : ${BROWSER} : Cannot Click on 1st Record : User ${USER}
        Return From Keyword
    END

    Run Keyword And Continue on Failure     Verify On Screen Text       "Asset Edit Page"     @{edit_term_list}             # validate screen text

    # click [Edit]
    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${SETTINGS_EDIT_BUTTON}           # click the [Edit] element
    Sleep   5s

    # click [Cancel]
    ${status}           Run Keyword And Return Status   SeleniumLibrary.Click Element     ${SETTINGS_EDIT_CANCEL_BUTTON}    # click the [Cancel] element
    Sleep   5s

    Run Keyword     Select Home Icon                                                                                    # Get out of Settings page