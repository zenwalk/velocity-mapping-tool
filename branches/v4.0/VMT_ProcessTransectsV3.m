function [A,V] = VMT_ProcessTransectsV3(z,A,setends,unitQcorrection)

%This routine acts as a driver program to process multiple transects at a
%single cross-section for velocity mapping.

%V2 adds the cpability to set the endpoints of the mean cross section

%V3 adds the Rozovskii computations for secondary flow. 8/31/09

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
       

try
    disp('Processing Data...')
    warning off
    %% Map ensembles to mean cross-section
    [A,V] = VMT_MapEns2MeanXSV2(z,A,setends);
    msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');

    %% Grid the measured data along the mean cross-section
    %[A,V] = VMT_GridData2MeanXS(z,A,V);
    [A,V] = VMT_GridData2MeanXS_INT(z,A,V,unitQcorrection);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');

    %% Computes the mean data for the mean cross-section 
    %[A,V] = VMT_CompMeanXS(z,A,V);
    [A,V] = VMT_CompMeanXS_old(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');  

    %% Decompose the velocities into u, v, and w components
    [A,V] = VMT_CompMeanXS_UVW(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace'); 

    %% Decompose the velocities into primary and secondary components
    [A,V] = VMT_CompMeanXS_PriSec(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace'); 

    %% Perform the Rozovskii computations
    [V] = VMT_RozovskiiV2(V,A);

    %figure(4); clf
    %plot3(V.mcsX,V.mcsY,V.mcsDepth(1))
    disp('Processing Completed')
catch err
    erstg = {'An unexpected error occurred during processing. Execution stopped.'};
    errordlg(erstg,'VMT Status','replace');
    rethrow(err)
    return
end


%% Notes:

%1. I removed scripts at the end of the original code that computes
%standard deviations (12-9-08)
