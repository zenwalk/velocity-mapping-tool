
# Output File Formats #

Data files can be exported from VMT that contain the processed data for archiving, use in other programs, and for review.  File formats include Matlab data files (`*.mat`), Tecplot data files (`*.dat`), iRIC vector files (`*.anv`), multibeam XYZ bathymetry files (`*_mbxyz.csv`), Google Earth files (`*.KML` and `*.KMZ`), and GIS compatible ascii files (`*_GIS.csv`).  Below is a summary of each data file format and a description of the data they contain.

## Matlab data files (`*.mat`): ##
Files contain Matlab data structures with the raw ADCP data, intermediate variables used in computations, and final processed and averaged data.  The data structures are extensive and will not be discussed in detail here. See [DetailedVMTFileStructure](DetailedVMTFileStructure.md) for a complete description.

### Tecplot Data files (`*.dat`): ###
Files contain processed and averaged ADCP data formatted for direct import into Tecplot.  Choosing the Tecplot export option will export the average cross-section data only with no smoothing or data reduction (vector spacing) applied.  Data files contain a header with all necessary information.  One data file (`*_TECOUT.dat`) contains the velocity and backscatter data array for the cross section while the other data file (`*_TECOUT_XSBathy.dat`) contains the georeferenced bed depth and bed elevation data.  The data files contain the following variables:

**TECOUT.dat**
```
NAME             DESCRIPTION                                    

X                UTM Easting (m)                                
Y                UTM Northing (m)                               
Depth            depth (m)                                      
Dist             dist across XS, oriented looking u/s (m)       
u                stream-wise velocity magnitude per bin (cm/s)  
v                cross-stream velocity magnitude per bin (cm/s) 
w                vertical velocity magnitude per bin (cm/s)     
vp               primary vel. component-0 discharge meth. (cm/s)
vs               secondary vel. comp.-0 discharge meth. (cm/s)  
U (Rotated)      depth-avg. stream-wise magnitude (cm/s)        
V (Rotated)      depth-avg. cross-stream magnitude (cm/s)       
ux (Rotated)     component of vel. in X dir., rotated (cm/s)    
uy (Rotated)     component of vel. in Y dir., rotated (cm/s)    
uz (Rotated)     component of vel. in Z dir., rotated (cm/s)    
Mag              vel magnitude (need better desc.) (cm/s)       
Bscat            backscatter (dB)                           
Dir              direction deviation (degrees)                  
vp (Roz)         primary vel. per bin using Rozovskii (cm/s)    
vs (Roz)         secondary vel. per bin using Rozovskii (cm/s)  
vpy (Roz)        cross-stream comp. of primary vel. (cm/s)      
vsy(Roz)         cross-stream comp. of secondary vel. (cm/s)    
phi_deg (Roz)    depth-avg. vel. vector angle (degrees)         
theta_deg (Roz)  individual bin vel. vector angle (degrees)
```

**TECOUT`_`XSBathy.dat**
```
NAME             DESCRIPTION                                    

X                UTM Easting (m)                                
Y                UTM Northing (m)                               
BedDepth         Bed depth (m)                                      
Dist             Dist across XS, oriented looking u/s (m)   
BedElev          Bed Elevation (m) (Only accurate if user entered value in VMT GUI)
```

## iRIC Vector Data Files (`*.anv`): ##
The iRIC river modeling interface allows input of vector velocity data for model calibration and validation (2-D) in the form of ANV files.  Currently (VMT v2.4xbeta) will export ANV files from the ASCII2GIS utility (depth-averaged velocity along the curvilinear boat path) and ANV files containing the depth- or layer-averaged velocity as displayed in the plan view plot with vector spacing and smoothing applied.  The format of these data files is as follows:

> The vector files contain x, y, z, vx, and vy values in each line and separated by spaces. Units are MKS.
> x: x position (UTM Easting in m)
> y: y position (UTM Northing in m)
> z: z position - Presently the z- value is unused and can be set to zero.
> vx: the x or easting component of velocity
> vy: the y or northing component of velocity.
> There is no header with the number of points in the file.
> The extension for vector files is .anv

**Example:**
```
  324149.52 855806.24 0 -0.157983784 0.003032246
  324149.36 855806.27 0 -0.223229456 0.039234629
  324149.26 855806.32 0 -0.124340297 0.073863539
  324149.02 855806.33 0 -0.205609318 0.079592921
  324148.7 855806.35 0 -0.056268607 0.036997848
  324148.36 855806.36 0 -0.326218383 0.032733164
  324148.09 855806.39 0 -0.352748183 0.081762639
  324147.78 855806.5 0 -0.605494602 0.625695435
```

### Multibeam XYZ Bathymetry Files (`*_mbxyz.csv`): ###
These files contain the bathymetry data from the four individual beams of the ADCP, corrected for heading, pitch, and roll using an algorithm provided by TRDI and in use in Dave Mueller’s ADMAP.  The data is formatted as a simple CSV (comma-separated value) file that is easily imported into ArcGIS using the XY data import tool.  The user has the option to add ancillary data to the data file.  A description of the data files with and without the ancillary data is as follows:
**Without Ancillary Data**
```
   NAME         DESCRIPTION                                    
   EnsNo        Ensemble Number
   Easting      Easting (UTM, WGS84) 
   Northing     Northing (UTM, WGS84)   
   Elev_m       Elevation in meters
```
**With Ancillary Data**
```
   NAME         DESCRIPTION                                    
   EnsNo        Ensemble Number
   Easting      Easting (UTM, WGS84) 
   Northing     Northing (UTM, WGS84)   
   Elev_m       Elevation in meters   
   Year         Year of sample
   Month        Month of sample
   Day          Day of sample
   Hour         Hour of sample
   Minute       Minute of sample
   Second       Second of sample
   Heading_deg  Heading reading at time of sample in degrees from true north
   Pitch_deg    Pitch reading at time of sample in degrees
   Roll_deg     Roll reading at time of sample in degrees
```

NOTE: UTM coordinates referenced to the WGS84 reference frame if that was set in the GPS unit used during data collection (typical).

### Google Earth files (`*.KML` and `*.KMZ`): ###
These files are generated to allow the user to display the transect shiptracks (`*.kml`) and mean cross sections (`*.kmz`) in Google Earth.  The KML files are generated using the VMT utility ASCII2KML and the KML files must be loaded into Google Earth for display.  The KMZ files are generated at the request of the user in the VMT interface and will open automatically in Google Earth through a request in the VMT code.  The KMZ files are best viewed as 3-D cross sections so the user should adjust the view in Google Earth to get the best display of the cross section.  In order to display each KMZ file as a 3-D cross section, the user must enter an offset in the VMT interface that is greater than or equal to the max depth in the reach.  This will ensure the cross section is fully displayed above the image plane in Google Earth.  Failure to enter an offset will place the cross section below the plane of the background image in Google Earth, thus blocking the view of the data.

### GIS Compatible ASCII Files (`*_GIS.csv`): ###
These files contain georeferenced depth- or layer-averaged data for every ensemble along the curvilinear shiptrack.  The file also includes ancillary data.  Data is formatted in a CSV file with a header that allows direct import in to ArcGIS using the XY data import tool.  A description of the data contained in the file is as follows:
**GIS.csv files**
```
NAME                DESCRIPTION                                    
EnsNo               Ensemble Number
Year                Year of sample
Month               Month of sample
Day                 Day of sample
Hour                Hour of sample
Min                 Minute of sample
Sec                 Second of sample
Lat_WGS84           Latitude in WGS84
Lon_WGS84           Longitude in WGS84
Heading_deg         Heading reading at time of sample in degrees from true north
Pitch_deg           Pitch reading at time of sample in degrees
Roll_deg            Roll reading at time of sample in degrees
Temp_C              Temperature at time of sample in deg. C
Depth_m             Mean bed depth at time of sample in meters
B1Depth_m           Beam 1 bed depth at time of sample in meters
B2Depth_m           Beam 2 bed depth at time of sample in meters
B3Depth_m           Beam 3 bed depth at time of sample in meters
B4Depth_m           Beam 4 bed depth at time of sample in meters
Backscatter_db      Acoustic backscatter in dB
DAVeast_cmps        Depth- or Layer-averaged velocity (east component) in cm/s
DAVnorth_cmps       Depth- or Layer-averaged velocity (north component) in cm/s
DAVmag_cmps         Depth- or Layer-averaged velocity magnitude in cm/s
DAVdir_deg          Depth- or Layer-averaged velocity direction in degrees from true north
DAVvert_cmps        Depth- or Layer-averaged velocity (vertical) in cm/s (+ is up)
U_Star_mps          Shear velocity estimate in m/s (currently disabled pending testing)
Z0_m                Roughness length estimate (currently disabled pending testing)
```