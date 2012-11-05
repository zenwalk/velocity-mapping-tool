function [A,V] = VMT_SmoothV3(A,V,hspc,vspc)

%This routine smooths some of the velocity data.

%V2 makes the moving average bins user selectable and set to the chosen
%quiver spacing (horizonal and vertical).

%V3 adds the Rozovskii variables 8/31/09
%Added the smooth2a option (PRJ, 9/27/10)


%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 

disp('Smoothing Data...')

%% Smooth

if 0 %A(1).Sup.binSize_cm == 25  %Singled out due to vertical velocity bias (turned off for now--PRJ--1-7-09)
    V.w(1:7,:) = NaN;
    % Fr  - Window semi-length in the rows.
    Fr = 4;
    % Fc  - Window semi-length in the columns.
    Fc = 20;
else
    % Fr  - Window semi-length in the rows.
    Fr = vspc; %1
    % Fc  - Window semi-length in the columns.
    Fc = hspc; %10
end
%
if 1  %Uses nanmoving_average2 for spatial averaging
    [V.vsSmooth,a] = nanmoving_average2(V.vs,Fr,Fc);
    [V.vSmooth,a] = nanmoving_average2(V.v,Fr,Fc);
    [V.wSmooth,b] = nanmoving_average2(V.w,Fr,Fc);
    [V.Roz.usSmooth,b] = nanmoving_average2(V.Roz.us,Fr,Fc);
    [V.Roz.upySmooth,b] = nanmoving_average2(V.Roz.upy,Fr,Fc);
    [V.Roz.usySmooth,b] = nanmoving_average2(V.Roz.usy,Fr,Fc);
else %uses smooth2a for spatial averaging
    [V.vsSmooth] = smooth2a(V.vs,Fr,Fc);
    [V.vSmooth] = smooth2a(V.v,Fr,Fc);
    [V.wSmooth] = smooth2a(V.w,Fr,Fc);
    [V.Roz.usSmooth] = smooth2a(V.Roz.us,Fr,Fc);
    [V.Roz.upySmooth] = smooth2a(V.Roz.upy,Fr,Fc);
    [V.Roz.usySmooth] = smooth2a(V.Roz.usy,Fr,Fc);
end
% [V.vpSmooth,b] = nanmoving_average2(V.vp,Fr,Fc);

%% Close out

disp('Smoothing Completed')
