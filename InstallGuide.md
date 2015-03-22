
# Installation of VMT and VMT Utilities #
## Running VMT in Matlab (recommended if possible): ##
Copy the ‘VMT’ directory and all its contents to your computer and set the directory within Matlab to the VMT directory. The easiest way to do this is to anonymously check out the Subversion Repository posted in this project page.  All custom functions called by VMT should be included in this directory and Matlab will look for them within this directory.  Matlab will also look to the Matlab program files for some built-in functions.  Errors may result if using old versions of Matlab and built in functions are not present.  Also, errors may result if the source code or functions are moved from the VMT directory, renamed, or modified.
To run VMT, simply type ‘VMT’ at the Matlab command prompt.  To run stand-alone utilities, simply type ‘ASCII2KML\_GUI’ or ‘ASCII2GIS\_GUI’ at the command prompt.

## Running the compiled version of VMT (for those without Matlab): ##
The compiled version of VMT 2.4b and later requires the installation of the [Matlab Runtime Library 2012a (v 7.17)](http://www.mathworks.com/products/compiler/mcr/index.html) on the host machine.

With the library installed, simply copy the ‘VMT.exe’ program to your computer and run the executable to launch the VMT program.  Note that some errors and output that are displayed in the Matlab command window will not be visible in the compiled version.  Stand-alone utilities (ASCII2KML & ASCII2GIS) are both run by double clicking the appropriate executable file.