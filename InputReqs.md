
# Input Data Requirements and Format #
## Data input requirements and format for VMT are as follows: ##
  1. Currently, the required input data format is the “ascii output” file format from WinRiver II
    1. Classic format
    1. Backscatter output
    1. **METRIC** units (all input data are in metric units, but figures can be plotted in English units)
    1. Ensure no spaces are in the file names (replace with underscore if necessary).  Spaces can cause problems in MatLab.
    1. Files should be of the standard format “`*_ASC.TXT`” (case does matter).  If the files you have do not work (maybe from a previous version of WR or WRII), try outputting new ascii files from the latest version of WRII and run VMT again.
  1. Data must include valid GPS data within the ascii file (currently does not read the `*.GPS.txt files`).
  1. Google Earth must be installed if outputting KMZ files (free download from Google).
  1. VMT is best suited for repeat transects at a single cross section (they will be used to compute an average cross section and velocity distribution).  The software will handle a single transect however.  Note that transects at a site with significant variation in the channel bathymetry and/or variation in the position of the transect may result in unusual averaging for the bathymetry and water velocities.  Processing single transects in this case is recommended and will preserve bathymetry and flow variation.
  1. It is helpful for the user to know the maximum depth within a study reach for setting the vertical offset and vertical exaggeration.  When multiple cross sections are mapped in a reach, the user should set these values for the transect with the maximum depth and keep these values constant for the remaining transect sites in the reach.  This ensures that vertical scaling and offsets are consistent throughout the reach (especially true for the KMZ offset—see below).
  1. The user should have notes handy that list the repeated transects at each cross section.  The user will be asked to select these ASCII output files at each cross section to determine the average cross section and velocity field for the cross section.  If filed notes are poor, the user can determine the spatial locations of each transect by using the ASCII2KML\_GUI utility (generates a Google Earth KML file for each transect shiptrack for easy identification of spatial positions).

> Note: VMT 2.4xb does not currently support data from other ADCP manufactures (e.g. SonTek M9 data) or data with dynamic bin size and/or frequency switching.  However, we are currently testing algorithms to handle this data and compatibility with other data types will be included in an upcoming version.