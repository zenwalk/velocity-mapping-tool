# Explanation of VMT Output Figures #
## Figure 1: ##
Transects (blue lines) are fit with a line (mean transect, green line) and data points (ensembles, blue dots) from each transect are mapped to mean transect and interpolated to the specified grid (black +).  Transect data are then averaged at each node to arrive at a mean data set.

![http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig1explained.png](http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig1explained.png)

## Figure 2: ##
Figure 2 is a planform plot of depth- or layer-averaged velocity.  When processing ASCII output data for a single cross section, the figure will contain only one (average) set of vectors along the average cross section.  Multiple cross sections can be viewed at once and all referenced to the same scale by loading `*.mat` files for preprocessed cross sections.  In the figure below, a background image containing the bathymetry (from the ADCP) has been loaded.  Bathymetry data was extracted from the ASCII files using VMT and imported into ArcGIS for krigging.  The final background image was exported from ArcGIS in UTM coordinates and imported into VMT.

![http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig2explained.png](http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig2explained.png)

## Figure 3: ##
Figure 3 displays the transect-averaged data in both a color-coded contour plot and a vector field.  The user controls what variables are plotted for both the contour plot and the vector field.  In addition, the user has the option to not include the vertical velocity component in the vector field.  Unmeasured area near the surface and bed is shown and no data is interpolated into these regions.  A colorbar provides the scale for the contour plot and a reference vector is provided for the vector field.

![http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig3explained.png](http://hydroacoustics.usgs.gov/movingboat/VMT/Wiki/images/Fig3explained.png)