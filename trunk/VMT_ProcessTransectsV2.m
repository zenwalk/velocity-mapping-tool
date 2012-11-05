function [A,V] = VMT_ProcessTransectsV2(z,A,setends)

%This routine acts as a driver program to process multiple transects at a
%single cross-section for velocity mapping.

%V2 adds the cpability to set the endpoints of the mean cross section

%Among other things, it:

% Determines the best fit mean cross-section line from multiple transects
% Map ensembles to mean c-s line
% Determine uniform mean c-s grid for vector interpolating
% Determine location of mapped ensemble points for interpolating
% Interpolate individual transects onto uniform mean c-s grid
% Average mapped mean cross-sections from individual transects together 
% Rotate velocities into u, v, and w components


%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 


disp('Processing Data...')

%% Map ensembles to mean cross-section
[A,V] = VMT_MapEns2MeanXSV2(z,A,setends);

%% Grid the measured data along the mean cross-section
%[A,V] = VMT_GridData2MeanXS(z,A,V);
[A,V] = VMT_GridData2MeanXS_old(z,A,V);
    
%% Computes the mean data for the mean cross-section 
%[A,V] = VMT_CompMeanXS(z,A,V);
[A,V] = VMT_CompMeanXS_old(z,A,V);

%% Decompose the velocities into u, v, and w components
[A,V] = VMT_CompMeanXS_UVW(z,A,V);

%% Decompose the velocities into primary and secondary components
[A,V] = VMT_CompMeanXS_PriSec(z,A,V);

%%
disp('Processing Completed')

%% Notes:

%1. I removed scripts at the end of the original code that computes
%standard deviations (12-9-08)
