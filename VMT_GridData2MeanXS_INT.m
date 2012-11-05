function [A,V] = VMT_GridData2MeanXS_INT(z,A,V,unitQcorrection)

%This routine generates a uniformly spaced grid for the mean cross section and 
%maps (interpolates) individual transects to this grid.   

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08

%% User Input

xgdspc = A(1).hgns; %Horizontal Grid node spacing in meters  (vertical grid spacing is set by bins)
if 0
    xgdspc = V.meddens + V.stddens;  %Auto method should include 67% of the values
    disp(['X Grid Node Auto Spacing = ' num2str(xgdspc) ' m'])
end


%% Determine uniform mean c-s grid for vector interpolating

%Determine the end points of the mean cross-section line  
%Initialize variable with mid range value
V.xe = mean(A(1).Comp.xm);
V.ys = mean(A(1).Comp.ym);
V.xw = mean(A(1).Comp.xm);
V.yn = mean(A(1).Comp.ym);

for zi = 1 : z
    
    V.xe = max(max(A(zi).Comp.xm),V.xe);
    V.ys = min(min(A(zi).Comp.ym),V.ys);
    V.xw = min(min(A(zi).Comp.xm),V.xw);
    V.yn = max(max(A(zi).Comp.ym),V.yn);
    
end

% Determine the distance between the mean cross-section endpoints
V.dx = V.xe-V.xw;
V.dy = V.yn-V.ys;

V.dl = sqrt(V.dx.^2+V.dy.^2);

% Determine mean cross-section velocity vector grid
V.mcsDist = linspace(0,V.dl,floor(V.dl/xgdspc));                                  %%linspace(0,V.dl,V.dl); Changed to make it user selectable (PRJ, 12-12-08)
V.mcsDepth = A(1).Wat.binDepth(:,1);
[V.mcsDist V.mcsDepth] = meshgrid(V.mcsDist,V.mcsDepth);

% Use the correctly oriented normal vector, or rather V.phi, to set the
% start bank so we are always starting on the left bank looking
% downstream (PRJ, 10-17-12)
    
if V.phi > 0 && V.phi < 90 %PHI quadrant 1
    xStart = V.xw;
    yStart = V.yn;
    xEnd   = V.xe;
    yEnd   = V.ys;
elseif V.phi > 90 && V.phi < 180 %PHI quadrant 2
    xStart = V.xe;
    yStart = V.yn;
    xEnd   = V.xw;
    yEnd   = V.ys;
elseif V.phi > 180 && V.phi < 270 %PHI quadrant 3
    xStart = V.xe;
    yStart = V.ys;
    xEnd   = V.xw;
    yEnd   = V.yn;
elseif V.phi > 270 && V.phi < 360 %PHI quadrant 4
    xStart = V.xw;
    yStart = V.ys;
    xEnd   = V.xe;
    yEnd   = V.yn;
elseif V.phi == 0 %Set special cases
    xStart = V.xw;
    yStart = V.yn; %Does not matter if use N or S point (same)
    xEnd   = V.xe;
    yEnd   = V.ys;
elseif V.phi == 90 
    xStart = V.xe; %Does not matter if use E or W point (same)
    yStart = V.yn; 
    xEnd   = V.xw;
    yEnd   = V.ys;
elseif V.phi == 180 
    xStart = V.xe;
    yStart = V.yn; %Does not matter if use N or S point (same)
    xEnd   = V.xw;
    yEnd   = V.ys;
elseif V.phi == 270 
    xStart = V.xe; %Does not matter if use E or W point (same)
    yStart = V.ys; 
    xEnd   = V.xw;
    yEnd   = V.yn;
end

% Define the MCS XY points. (REVISED PRJ, 10-18-12)
% Coordinate assignments depend on the starting 
% point and the slope of the cross section. Theta is limited to 0 to 180
% (geographic) and 90 to 270 (arithmetic).  For COS, arithmetic angles
% between 90 and 270 are always negative so no need to add additional IF
% statement based on the slope.  However, SIN theta (aritmetic) is positive 
% in MFD quadrants 2 and 4 and negative in 1 and 3. Therefore, we use the slope
% (positive in MFD quadrants 1 and 3, negative in 2 and 4) to determine whether to add or
% subtract the incremental distances from the start point.  (MFD = mean
% flow direction, used to define quadrants above and below)

if xStart == V.xe % MFD Quadrants 2 and 3 (east start)
    V.mcsX = xStart - V.mcsDist(1,:).*cosd(geo2arideg(V.theta));
else % MFD Quadrants 1 and 4 (west start)
    V.mcsX = xStart + V.mcsDist(1,:).*cosd(geo2arideg(V.theta));
end

if yStart == V.yn % MFD Quadrants 1 and 2 (north start)
    if V.m >= 0 %MFD Quadrant 2
        V.mcsY = yStart - V.mcsDist(1,:).*sind(geo2arideg(V.theta)); 
    else %MFD Quadrant 1
        V.mcsY = yStart + V.mcsDist(1,:).*sind(geo2arideg(V.theta));
    end
else % MFD Quadrants 3 and 4 (south start)
    if V.m >= 0 %MFD Quadrant 4
        V.mcsY = yStart + V.mcsDist(1,:).*sind(geo2arideg(V.theta)); 
    else %MFD Quadrant 3
        V.mcsY = yStart - V.mcsDist(1,:).*sind(geo2arideg(V.theta));
    end
end


%Plot the MCS on figure 1
figure(1); hold on
plot(xStart,yStart,'gs','MarkerFaceColor','g'); hold on  %Green left bank start point
plot(xEnd,yEnd,'rs','MarkerFaceColor','r'); hold on %Red right bank end point
plot(V.mcsX,V.mcsY,'k+'); hold on
%plot(V.mcsX(1),V.mcsY(1),'y*'); hold on

% Determine the angle the mean cross-section makes with the
% x-axis (longitude)
% Plot mean cross-section line
% if V.m >= 0
%     %V.theta = atand(V.dy./V.dx);
%     
%     figure(1); hold on
%     plot([V.xe V.xw],[V.yn V.ys],'ks'); hold on
%     
%     V.mcsX = V.xe-V.mcsDist(1,:).*cosd(geo2arideg(V.theta));            % 
%     V.mcsY = V.yn-V.mcsDist(1,:).*sind(geo2arideg(V.theta)); 
%     
% %     if V.mfd >= 270 | V.mfd < 90 %Flow to the north  %This code was an attempt to auto detect left bank--did'nt work so removed.  
% %         V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
% %         V.mcsY = V.ys+V.mcsDist(1,:).*sind(V.theta);
% %         
% %     elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
% %         V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);            % 
% %         V.mcsY = V.yn-V.mcsDist(1,:).*sind(V.theta);  
% %     end%
%     
%     plot(V.mcsX,V.mcsY,'k+'); hold on
%     plot(V.mcsX(1),V.mcsY(1),'y*'); hold on
% 
% elseif V.m < 0
%     %V.theta = -atand(V.dy./V.dx);
%     %V.theta = atand(V.dy./V.dx); %Changed 9-28-10, PRJ (theta needs to be
%     %negative--changed back to original)
%     
%     figure(1); hold on
%     plot([V.xe V.xw],[V.ys V.yn],'ks'); hold on
%     
%     V.mcsX = V.xe-V.mcsDist(1,:).*cosd(geo2arideg(V.theta));
%     V.mcsY = V.ys-V.mcsDist(1,:).*sind(geo2arideg(V.theta));
%     %V.mcsY = V.ys+V.mcsDist(1,:).*sind(V.theta);  %Changed 9-28-10, PRJ
%     
% %     if V.mfd >= 270 | V.mfd < 90 %Flow to the north
% %         V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
% %         V.mcsY = V.yn+V.mcsDist(1,:).*sind(V.theta);
% %         
% %     elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
% %         V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);
% %         V.mcsY = V.ys-V.mcsDist(1,:).*sind(V.theta);  
% %     end%
%    
%     plot(V.mcsX,V.mcsY,'k+'); hold on
%     plot(V.mcsX(1),V.mcsY(1),'y*'); hold on
%     
% end

V.mcsX = meshgrid(V.mcsX,V.mcsDepth(:,1));
V.mcsY = meshgrid(V.mcsY,V.mcsDepth(:,1));
figure(1); set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
clear zi

% Format the ticks for UTM and allow zooming and panning
figure(1);
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm_fig1 = zoom;
set(hdlzm_fig1,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm_fig1,'Enable','on');
hdlpn_fig1 = pan;
set(hdlpn_fig1,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn_fig1,'Enable','on');


%% Determine location of mapped ensemble points for interpolating
% For all transects

%A = VMT_DxDyfromLB(z,A,V); %Computes dx and dy 

for zi = 1 : z  %FIXME  This loop is responsible for nearly half of the total run time for VMT.

    % Compute the change in X an Y from the start point to each observation     
    A(zi).Comp.dx = abs(xStart - A(zi).Comp.xm);  %Revised (PRJ, 10-17-12)
    A(zi).Comp.dy = abs(yStart - A(zi).Comp.ym);  

    % Determine the distance in meters from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
    A(zi).Comp.dl = sqrt(A(zi).Comp.dx.^2+A(zi).Comp.dy.^2);

    % Sort vectors by dl
    A(zi).Comp.dlsort = sort(A(zi).Comp.dl,'ascend');

    % Map indices  %FIXME  This computation is VERY slow.  Suggest revising
    % for speed
    for i = 1 : A(zi).Sup.noe
        for k = 1 : A(zi).Sup.noe

            if A(zi).Comp.dlsort(i,1) == A(zi).Comp.dl(k,1)
                A(zi).Comp.vecmap(i,1) = k;

            end
        end
    end

    % GPS position fix
    % if distances from the left bank are the same for two ensembles the
    % the position of the right most ensemble is interpolated from adjacent
    % ensembles
    % check for repeat values of distance
    sbt(:,1)=diff(A(zi).Comp.dlsort);
    chk(1,1)=1;
    chk(2:A(zi).Sup.noe,1)=sbt(1:end,1);

    % identify repeat values
    A(zi).Comp.sd = (chk==0) > 0;

    % if repeat values exist interpolate distances from adjacent ensembles
    if sum(A(zi).Comp.sd) > 0

        % bracket repeat sections
        [I,J] = ind2sub(size(A(zi).Comp.sd),find(A(zi).Comp.sd==1));
        df=diff(I);
        nbrk=sum(df>1)+1;
        [I2,J2] = ind2sub(size(df),find(df>1));

        bg(1)=(I(1)-1);

        for n = 2 : nbrk
            bg(n)=(I(I2(n-1)+1)-1);
        end

        for n = 1 : nbrk -1
            ed(n)=(I(I2(n))+1);
        end

        ed(nbrk)=I(end)+1;

        % interpolate repeat values
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;

        for i = 1 : nbrk
            for j = bg(i)+1 : ed(i)-1
                % interpolate
                if bg(i) > 0 && ed(i) < length(A(zi).Nav.lat_deg)

                    den=(ed(i)-bg(i));
                    num2=j-bg(i);
                    num1=ed(i)-j;

                    A(zi).Comp.dlsortgpsfix(j,1)=...
                        (num1/den).*A(zi).Comp.dlsort(bg(i))+...
                        (num2/den).*A(zi).Comp.dlsort(ed(i));

                end
                
                % extrapolate end
                if ed(i) > length(A(zi).Nav.lat_deg)
                   
                    numex=ed(i)-length(A(zi).Nav.lat_deg);
                    
                    A(zi).Comp.dlsortgpsfix(j,1)=numex.*...
                        (A(zi).Comp.dlsort(bg(i))-...
                        A(zi).Comp.dlsort(bg(i)-1))+...
                        A(zi).Comp.dlsort(bg(i));
                    
                end               
            end
        end

    else
        
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;
        
    end
    
    % Determine velocity vector grid for individual transects
    [A(zi).Comp.itDist A(zi).Comp.itDepth] = ...
        meshgrid(A(zi).Comp.dlsortgpsfix,A(zi).Wat.binDepth(:,1));
    
    clear I I2 J J2 bg chk df ed i j nbrk sbt xUTM yUTM n zi...
        den num2 num1 numex
    
end

clear zi i k check

%% If specified, correct the streamwise velocity by enforcing mass 
% flux (capacitor) continuity
if unitQcorrection
    A = VMT_unitQcont(A,V,z);
end

%% Interpolate individual transects onto uniform mean c-s grid
% Fill in uniform grid based on individual transects mapped onto the mean
% cross-section by interpolating between adjacent points

%ZI = interp2(X,Y,Z,XI,YI)
for zi = 1 : z
 
    A(zi).Comp.mcsBack = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.bs(:,A(zi).Comp.vecmap),V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsBack(A(zi).Comp.mcsBack>=255) = NaN;
    
    %A(zi).Comp.mcsDir = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        %A(zi).Clean.vDir(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth); %This interpolation scheme has issues when interpolating in a flow due north (0,360 interpolate to 180)
    
    % For direction, must convert degrees to radians, take the sin of the
    % radians, and then interpolate.  Following interpolation, convert
    % radians back to degrees. (PRJ, 9-28-10)  ALSO BAD NEAR 180
    %A(zi).Comp.mcsDir = 180/pi*(interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        %sin(pi/180*(A(zi).Clean.vDir(:,A(zi).Comp.vecmap))), V.mcsDist, V.mcsDepth));
    
%     A(zi).Comp.mcsMag = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
%         A(zi).Clean.vMag(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
%         (Recomputed from north and east components (PRJ, 3-21-11) 
    
    
    A(zi).Comp.mcsEast = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vEast(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsNorth = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vNorth(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsVert = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vVert(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    
    %Compute magnitude
    A(zi).Comp.mcsMag = sqrt(A(zi).Comp.mcsEast.^2 + A(zi).Comp.mcsNorth.^2);
    
    
    %For direction, compute from the velocity components
    A(zi).Comp.mcsDir = ari2geodeg((atan2(A(zi).Comp.mcsNorth,A(zi).Comp.mcsEast))*180/pi); 
%     A(zi).Comp.mcsDir = 90 - (atan2(A(zi).Comp.mcsNorth, A(zi).Comp.mcsEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
%     qindx = find(A(zi).Comp.mcsDir < 0);
%     if ~isempty(qindx)
%         A(zi).Comp.mcsDir(qindx) = A(zi).Comp.mcsDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
%     end
    
    A(zi).Comp.mcsBed  = interp1(A(zi).Comp.itDist(1,:),...
        nanmean(A(zi).Nav.depth(A(zi).Comp.vecmap,:),2),V.mcsDist(1,:));
    
end

clear zi

%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 
