# Python style variables file
import  os
import datetime

PATH_SEPERATOR  = os.sep
CURRENT_YEAR = datetime.datetime.today().year                                                       # get the current year value
PIPE_CHAR    = "|"


MAIN_BROWSER_WINDOW = "xpath=//body"


# Buttons

RESET_BUTTON = "xpath=//button[@id='reset']"                                            # Reset Button - top of page
WEIGH_BUTTON = "xpath=//button[@id='weigh']"                                            # Weigh Button - top of page

# TEXT

#WEIGHING_TEXT = "xpath=//div[@class='game-info']//ol"                                    # result text
WEIGHING_TEXT = "xpath=//div[@class='game-info']//ol"                                    # result text



# INPUT

LEFT_INPUT_BOX  = "xpath=//input[@id='left_0']"
RIGHT_INPUT_BOX = "xpath=//input[@id='right_0']"



DIALOG_FILE_INPUT_LOCATOR   = "xpath=//input[@type='text']"                             # On Dialog - filename input
DIALOG_OK_BUTTON            = "xpath=//button[normalize-space()='OK']"                  # On Dialog - [OK] button
DIALOG_RENAME_BUTTON        = "xpath=//button[normalize-space()='Rename']"              # On Dialog - [Rename] button
DIALOG_SAVE_BUTTON          = "xpath=//button[normalize-space()='Save']"                # On Dialog - [Save] button
NOTEBOOK_TEXT_LOCATOR       = "xpath=//div[@role='presentation']"                       # notebook control - enter text here
NOTEBOOK_RUN_BUTTON         = "xpath=//button[@aria-label='Run']"                       # notebook control - Run




# Misc Keyboard Constants

CARRIAGE_RETURN = '\\13'                                                        # keycode for carriage return
TAB             = '\\9'                                                         # keycode for TAB
CTRL_T          = '\\20'                                                        # keycode for Ctrl-T
ESC_KEY         = '\\27'                                                        # keycode for ESC
LEFT_ARROW      = '\\37'                                                        # left arrow
UP_ARROW        = '\\38'                                                        # up arrow
RIGHT_ARROW     = '\\39'                                                        # right arrow
DOWN_ARROW      = '\\40'                                                        # down arrow
BACKSPACE_KEY   = '\\08'                                                        # backspace key


