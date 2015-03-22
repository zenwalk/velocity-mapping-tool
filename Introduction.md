
# Velocity Mapping Toolbox #

## Background ##
VMT is a Matlab-based software for processing and visualizing ADCP data collected along transects in rivers or other bodies of water. VMT allows rapid processing, visualization, and analysis of a range of ADCP datasets and includes utilities to export ADCP data to files compatible with ArcGIS, Tecplot, and Google Earth. The software can be used to explore patterns of three-dimensional fluid motion through several methods for calculation of secondary flows (e.g. Rhoads and Kenworthy, 1998; Lane et al., 2000). The software also includes capabilities for analyzing the acoustic backscatter and bathymetric data from the ADCP. A user-friendly graphical user interface (GUI) enhances program functionality and provides ready access to two- and three- dimensional plotting functions, allowing rapid display and interrogation of velocity, backscatter, and bathymetry data.

## Purpose and Scope ##
To-date no standard technique exists for combining velocity data from multiple ADCP transects to produce a composite depiction of three-dimensional velocity fields. To address this important need, the a new software tool has been developed, the Velocity Mapping Toolbox (VMT), for processing, analyzing, and displaying velocity data collected along multiple ADCP transects.

## Running VMT and Data Input ##
VMT can be run using either the Matlab source code (recommended) or compiled executables.  Users with access to Matlab are encouraged to run the source code for the most versatility.  However, some older versions of Matlab, e.g. 7.0.4, are not able to run GUIs like VMT that are created with newer versions of Matlab.  In this case, run the executables rather than the source code.  The VMT and utility executables require the [Matlab Runtime Library 2012a 32 bit](http://www.mathworks.com/products/compiler/mcr/index.html) to be installed prior to running. Input to the Matlab-based toolbox consists of ASCII output files from the Teledyne RD Instruments<sup>1</sup> ADCP data-collection software.
<img width='600' alt='VMT Layout' src='http://hydroacoustics.usgs.gov/movingboat/VMT/VMTLayout.png'>

<h2>Discussion of Computations</h2>
The main processing component of the software projects data collected along several irregular ship tracks, or measurement transects, onto a straight-line plane that defines a measurement cross section. The velocity data from individual transects are then averaged to produce a composite representation of the cross-sectional flow field. For more details see Velocity Mapping Toolbox (VMT): a processing and visualization suite for moving-vessel ADCP measurements, ESPL, by Parsons et al. (2013).<br>
<br>
<h2>Limitations</h2>
<ul><li>Only moving-boat transects are supported. The software does not support stationary profile data.<br>
</li><li>Presently (2012) the software only accepts input from TRDI Rio Grande<sup>1</sup> ADCPs; it does not support input from other ADCP manufacturers/models.<br>
</li><li>The program has not been tested extensively on many platforms.  Some issues may result with plotting, saving figures, etc. on platforms with different graphics capabilities and screen resolution.  Please report these issues via the VMT forum.<br>
</li><li>Due to forward compatibility issues, the current version of VMT (2.42b) is not compatible with older versions of Matlab (e.g. 7.0.4).  If you experience issues of matlab crashing when running VMT, please either upgrade Matlab to the newest version or run the compiled version of VMT.<br>
</li><li>VMT includes some error handling, however, not all errors have been encountered.  Matlab users will encounter error reports in the command window that identify the problem, however, users of the compiled version of VMT will not get such error reports.  We have tried to identify the most common errors and provide the user with feedback in the status window.  Please report errors and crashes if encountered.</li></ul>


<sup>1</sup>The use of trade, product, or firm names is for descriptive purposes only and does not imply endorsement by the U.S. Government.<br>
<br>
<h2>Selected References</h2>
<ol><li>Parsons, D. R., Jackson, P. R., Czuba, J. A., Engel, F. L., Rhoads, B. L., Oberg, K. A., Best, J. L., Mueller, D. S., Johnson, K. K. and Riley, J. D. (2013), Velocity Mapping Toolbox (VMT): a processing and visualization suite for moving-vessel ADCP measurements. Earth Surf. Process. Landforms. doi: 10.1002/esp.3367<br>
</li><li>Lane, S.N., K.F. Bradbrook, K.S. Richards, P.M. Biron, and A.G. Roy (2000) Secondary circulation cells in river channel confluences: Measurement artefacts or coherent flow structures?, Hydrol. Processes, 14, 2047- 2071.<br>
</li><li>Rhoads, B.L., and S.T. Kenworthy (1999) On secondary circulation, helical motion and Rozovskii-based analysis of time-averaged two-dimensional velocity fields at confluences. Earth Surface Processes and Landforms, 24, 369-375.