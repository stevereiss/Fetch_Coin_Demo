=========================================================================

Fetch SDET Coding Exercise
--------------------------


Steve Reiss - sreisscruz@gmail.com




Robot Framework Testing:
-------------------------

	- Quantamatics Website
		- General testing (Folders / Apps)
		- Mobius

	- POP View
 

Python Packages Needed:
------------------------

pip install faker
pip install httpagentparser

pip install selenium
pip install robotframework
pip install robotframework-pythonlibcore
pip install robotframework-seleniumlibrary


Versions Used in Test
----------------------
robotframework                      7.0
robotframework-pythonlibcore        4.4.1
robotframework-requests             0.9.7
robotframework-seleniumlibrary      6.2.0



Environment Configuration
-------------------------
    
1)  Create Temp Directorys :

   mkdir C:\Temp
   mkdir C:\Temp\Output



Testing Environment
--------------------


<DIR>          Common
 	 	
		__init__.py
	  	Faker_Data_Generator.py			- Custom Python Routines needed for My framework
	  	locators.py				- XPath locator for My Framework
	  	resource.robot				- Browser & Common routines for My Framework
  		resource_Gold_Coin.robot		- Routines for Gold Coin Test
  		resource_SmokeTest.robot		- Test Cases


<DIR>          Output
		
		robot_Gold_Coin_test.html 		- Run output Report 
		robot_Gold_Coin_test.xml		- Results file in XML format
		17,181 selenium-screenshot-1.png	- screen shot for Report (above)

<DIR>          Smoke_Tests

            
           Fetch_Coding_Exercise_SDET.pdf		- Test Spec File
           Gold_Coin_Test_In_Chrome.jpg			- Cmd-line Output of test run on Chrome Browser
           Gold_Coin_Test_In_Edge.jpg			- Cmd-line Output of test run on Edge Browser
           README.md					- THIS File - how to setup and run
           Robot_Frame_Report_Gold_Coin_Test.jpg	- Screen shot of Robot Framework Report



Browser Installs and Support Drivers:
---------------------------------------


1) Chrome - Current version 126.x  


      Chromedriver Download  

        https://googlechromelabs.github.io/chrome-for-testing/

      --------------------------

		Look for Section : Stable

	==>>	chromedriver	win64    https://url-to-file


		- Open Zip file with File Manager
		- copy chromedriver.exe to C:\Windows - Overwrite existing driver


2) Edge -  Driver

	***  Edge Browser appears to be the most stable and usable for Automation  ***


	https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/


	edgedriver_win64.zip

	msedgedriver.exe  <<=== Driver


		- Open Zip file with File Manager
		- copy msedgedriver.exe to C:\Windows





Browser Values - on Command-line
--------------------------------

  Chrome    - Careful - seeing "zombie" Chrome processes after many automation runs

  Edge	    - The most stable and usable browser & driver


=============================================

Command Line Examples
---------------------


Running the Smoke Tests:
-------------------------

from location :  Fetch_Coin_Demo >


For Browsers : Chrome / Edge:
-----------------------------

Edge
------

  \Fetch_Gold_Coin_Test > robot --variable browser:Edge --test "Coin Test" --xunit C:\Temp\Output\robot_Gold_Coin_test.xml --log C:\Temp\Output      
  \robot_Gold_Coin_test.html  --report None Smoke_Tests\Gold_Coin_Test.robot                                                                  


Chrome
------

\Fetch_Gold_Coin_Test > robot --variable browser:Chrome --test "Coin Test" --xunit C:\Temp\Output\robot_Gold_Coin_test.xml --log C:\Temp\Output\robot_Gold_Coin_test.html  --report None Smoke_Tests\Gold_Coin_Test.robot                                                                  
  



