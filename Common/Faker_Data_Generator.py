import string
import subprocess
import urllib.parse
import hashlib
import collections
import httpagentparser


import warnings
warnings.filterwarnings('ignore')


# *** NAME OF THIS CLASS AND THE FILE NAME MUST BE THE SAME TO WORK IN ROBOT FRAMEWORK  ***

class Faker_Data_Generator():


    def __init__(self):
        
        self.TAB = "\t"


    def get_browser_agent(self, agent_string):
        """
         Get the browser agent (browser ver & platform) from an agent_string

        :param agent_string: the agent string from the browser

        :return: string - "BROWSER nn.n on PLATFORM" ex Firefox 57.0 on Linux
        """

        temp_list = httpagentparser.simple_detect(agent_string)                 # get the brower & plaform info from package
        temp_string = "%s on %s" % (temp_list[1], temp_list[0])                 # create the return string

        return temp_string


    def GetDriverInfo(self, driver_name):
        """GetDriver Info
            driver_name : string = Chrome | Firefox
        
            Returns :

            ChromeDriver n.nn.nnnn
            OR
            geckodriver n.nn.n
            
        """

        element = 1

        if driver_name == "Chrome":                                             # Chromedriver
            temp_tuple = subprocess.getstatusoutput('chromedriver -v')            # get version from cmd-line : ChromeDriver n.nn.nnnn (nnnnnnnn)
            base_list = temp_tuple[element].split(" ")                          # break string on space - need element 0, 1
            driver_string = f"{base_list[0]},{base_list[1]}"                # combine list elements : 0,1 =  ChromeDriver 2.41.578700

        elif driver_name == "Firefox":                                          # Firefox geckodriver
            try:
                temp_tuple = subprocess.getstatusoutput('geckodriver -V')             # get version from cmd-line - list with 3 lines of output : 1536701394555<TAB>geckodriver<TAB>INFO<TAB>geckodriver 0.20.1
                print(f"temp_tuple = {temp_tuple}")
                base_string = temp_tuple[element].split("\n")[0]                     # break 3 lines of output on CR - keep element 0
                driver_string = base_string                                         # save line 0

            except Exception as error_msg:
                driver_string = f"Error Getting Driver Info : {driver_name} : {error_msg}"


        else:
            driver_string = ""                                                  # NO Match - return empty string



        return driver_string                                                    # return the driver string

    def CustomKeyPress(self, key_string):
        keyboard.press(key_string)


    def encode_url(self, value):
        """
        safe encode a value for requests

        :param value:  the value to encode

        :return:
            string in with url encoding
        """

        return urllib.parse.quote(value, safe="")  # return url safe string


    def create_checksum(self, the_text, debug_flag):
        """
         Create a sha 256 checksum from input text.

        :param the_text: string to perform checksum
                debug_flag : Boolean = flag to show text & stripped text

        :return:
            string : hexdigest of the input text
        """

        if debug_flag:
            print(f"The Page Text :\n\n{the_text}\n")

        hash_object = hashlib.sha256()                                                  # Create a hash object using the SHA-256 algorithm

        stripped_text = the_text.translate({ord(c): None for c in string.whitespace})   # Remove any common whitespace/tab/returns from string

        if debug_flag:
            print(f"The Stripped Text : \n\n{stripped_text}\n")

        text_bytes = stripped_text.encode('utf-8')                                      # Convert the text input to bytes
        hash_object.update(text_bytes)                                                  # Update the hash object with the text bytes
        checksum = hash_object.hexdigest()                                              # Get the hexadecimal representation of the hash digest

        return checksum                                                                 # Return the checksum




###############################################################################
#                   M A I N L I N E
###############################################################################
def main():

    fakeObj =  Faker_Data_Generator()



if __name__ == "__main__":
  main()
