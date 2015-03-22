
## Version 1.1: ##
  * Added the capability to compute and output multibeam bathymetry (individual beam depths) corrected for heading, pitch and roll.  Routine taken from ADMAP by D. Mueller.
  * Added the ability to manually set the mean cross section end points.  Input file is a CSV file with two sets of easting and northing coordinates (x,y).  Can be used to ensure data is mapped to the same line for comparison between repeated surveys. (suggested by B. Rhoads)
  * Added the ability to choose the vertical vector spacing in secondary vector contour plot (fixed in previous versions to 2)
  * Changed some plotting routines to improve figures
  * Fixed some minor bugs (see above)
## Version 2.1: ##
  * Added the Rozovskii definition for secondary flow computation.  Routine taken from code by F. Engel (UIUC).
  * Added ability to export velocity and backscatter data to Tecplot. Routine taken from code by F. Engel (UIUC). Unsmoothed data is exported to Tecplot.
  * Added Status windows reporting progress.
  * Expanded the list of variables to select for contour plotting
  * Added a user selectable list of variables for secondary flow vector field
  * Added the ability to remove the vertical velocity from the secondary flow vectors
  * Made smoothing parameters accessible to user within the GUI.  No longer tied to vector spacing parameters (ver 1.1).  Smoothing can be turned off by setting all window sizes to zero.
  * Smoothing filter now smoothes both the vector field and contour plot data before plotting.
  * Updated the GUI interface
  * Updated appearance of plots
## Version 2.3b: ##
  * 4-8-10: Updated VMT\_RepBadGPS.m to prescreen latitudes and longitude values that fall outside of the possible range.  Values outside this range caused the program to crash when converting to UTM.
  * 4-8-10: Added header to Multibeam export file (VMT\_MBbathyV2.m)
  * 9-28-10: Fixed bug in VMT\_GridData2MeanXS\_INT(z,A,V)where the interpolation of north flow directions (0 and 360) resulted in south flow.  Now converts to radians and interpolates the sine of the direction and converts back to degrees.—ALSO Flawed near 180 degrees.  See below
  * 9-28-10: Switched from nonmoving\_average2 to smooth2a.m for 2-d spatial averaging (same except for edges—see Test\_interp.m) in VMT\_SmoothV3.  Don’t actually use this script anymore, see 9-30-10 update.
  * 9-29-10: Fixed bug with flow direction computations.  Now computing the mean flow direction in each cell from the interpolated and averaged cross section velocity components (rather than interpolating and averaging the flow direction reported by the adcp).  This bypasses issues with averaging the flow direction which wraps from 0-360 degrees.
  * 9-30-10: Updated VMT\_SmoothVar to use either smooth2a.m or nanmoving\_average2.  User choice.
  * 9-30-10: Fixed bug in plotting of color bar in ASCII input plan view plot.  Axes were plotting as black rather than white.
  * 9-30-10: Fixed bug where figure 2 axes titles would not change color during graphic export.
  * 9-30-10: Added Print and Presentation options for graphics export format.
  * 9-30-10: Changed “Flow angle—theta (ROZ)” contour option to Flow Direction (deg from north).  Flow direction now should be the same as what is displayed in WinRiver (but contouring around 0 or 360 can look a little funny).
  * Oct 2010: Added DOQQ overlay
  * Jan 2011: Added computation of longitudinal dispersion coefficient (currently disabled pending testing)
  * Feb 16, 2011: Removed standard deviation screening of backscatter as it was causing unnecessary loss of data due to variation between backscatter in beams.
  * Spring 2011: Added English units plotting option
  * Spring 2011: Added advanced processing button link (currently disabled)
  * Spring 2011: Changes magnitude variable to include vertical velocity in computation (previously only N and E values used).
  * Spring 2011: Added computation of bed elevation given WSE in meters provided by the user in the bathymetry export box.  Default is 0.0 m above MSL (yields negative elevations).  Depth is still ised in plotting.
  * Spring 2011: Added second Tecplot output file with cross section bathymetry (X,Y,depth,distance,elev).
  * Spring 2011: Created GUIs for ASCII2KML and ASCII2GIS
  * Spring 2011: Added the ability to plot depth- or layer-averaged vectors on background without snapping to a line (see ASCII2GIS\_GUI)
  * Spring 2011: Added `* .anv` file output from ASSCII2GIS\_GUI script (vector input files for iRIC modeling interface).
  * Spring 2011: Added `* .anv` file export capability for plan view data (currently locked pending testing).

## Version 2.4b: ##
  * 11-7-11: Fixed bug in TecPlot bathy export file that caused files to not load properly into Tecplot.
  * 11-22-11: Fixed issue with ASSCII2KML not outputting coordinates properly (Google Earth changed the format of their input in the latest GE release).
  * 3-20-12: Added temporal averaging capability to ASCII2GIS utility
  * 3-20-12: Added sensor screening to tfile.m (heading, pitch, roll, temperature)
  * 3-23-12: Fixed issue with GE output in VMT (3-D cross section compatibility issue with latest GE).
  * 3-23-12: Added error dialog for failed `* .MAT` file read.
  * 3-28-12: Fixed bug related to plan view vector scale inconsistency between ASCII file and MAT file when using same vector scale settings.  Problem was related to NAN values in the ASCII data fed to quiverc.m causing slight changes in the output vector scale.  Omitted all Nan values prior to feeding vector components to quiverc.m (changes made in PlotPlanViewQuiversASCv3.m and PlotPlanViewQuiversMATv3.m).
  * 3-29-12: Updated VMT\_PlotXSContQuiverV4.m to use the maximum of the absolute value of the secondary velocity as the reference vector magnitude (it use to take the max without the absolute value possibly leading to a negative value if all secondary vectors are negative such as with a large flow angle and the secondary flow component set to transverse).
  * 4-9-12: (PRJ) Added error handling for all inputs in GUI trying to catch situations when users enter bad values for parameters (non integer values, negative values, zero, etc).
  * 4-9-12: (PRJ) Added a HELP button on the GUI that links to user manual PDF.  Requires a file VMTUserGuide.pdf to be in the VMT directory with the code else it returns an error.
  * 4-9-12: (PRJ) Added a TRY/CATCH statement on the tfile.m execution in VMT\_ReadFiles.m to catch any errors when reading ASCII files.  VMT now reports the unknown error when reading the ASCII files and reports to the user the error in a window along with the problem file name.
  * 6-19-12: (PRJ, FEL) Added transect number to the CSV output from VMT\_MBBathyV2.m
  * 8-7-12: (PRJ) Added export button for ANV file creation for depth- and layer-averaged vectors
  * 8-7-12: (PRJ) Turned off option for KMZ offset unless KMZ output is selected
  * 8-7-12: (PRJ) Added capability to handle WSE time series files
  * 8-7-12: (PRJ) Added EPS figure export option
  * 8-7-12: (PRJ) Added help and disclaimer buttons

## Version 2.42b: ##
  * 10-15-12: (FLE) Optimized tfile.m runtime performance. The new tfile runs approx. 4-5 times faster, and also includes a waitbar for user feedback.
  * 10-15-12: (FLE) Added the capability to correct for streamwise variations in depths. Updated the GUI to allow access to this functionality (the default is to have this functionality turned off).