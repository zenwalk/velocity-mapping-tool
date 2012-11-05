function [A,V] = VMT_SmoothV2(A,V,hspc,vspc)

%This routine smooths some of the velocity data.

%V2 makes the moving average bins user selectable and set to the chosen
%quiver spacing (horizonal and vertical).


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
[V.vsSmooth,a] = nanmoving_average2(V.vs,Fr,Fc);
[V.vSmooth,a] = nanmoving_average2(V.v,Fr,Fc);
[V.wSmooth,b] = nanmoving_average2(V.w,Fr,Fc);
% [V.vpSmooth,b] = nanmoving_average2(V.vp,Fr,Fc);

%% Close out

disp('Smoothing Completed')
