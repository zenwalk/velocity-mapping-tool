function [A,V] = VMT_CompMeanXS(z,A,V)

%This routine computes the mean cross section data from individual transects 
%that have been previously mapped to a common grid. 

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 



%% Average mapped mean cross-sections from individual transects together 
% Assign mapped uniform grid vectors to the same array for averaging
for zi = 1 : z
    
    Back(:,:,zi) = A(zi).Comp.mcsBack(:,:);
    Dir(:,:,zi) = A(zi).Comp.mcsDir(:,:);
    Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
    East(:,:,zi) = A(zi).Comp.mcsEast(:,:);
    North(:,:,zi) = A(zi).Comp.mcsNorth(:,:);
    Vert(:,:,zi) = A(zi).Comp.mcsVert(:,:);
    Bed(:,:,zi) = A(zi).Comp.mcsBed(:,:);

end

numavg = nansum(~isnan(Mag),3);
numavg(numavg==0) = NaN;
enscnt = nanmean(numavg,1);
[I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to >= 1 PRJ 12-10-08  (uses data even if only one measurement)

Backone= Back;
Magone = Mag;
Vertone = Vert;
Bedone = Bed;

Backone(~isnan(Back))=1;
Magone(~isnan(Mag))=1;
Vertone(~isnan(Vert))=1;
Bedone(~isnan(Bed))=1;

V.countBack = nansum(Backone,3);
V.countMag = nansum(Magone,3);
V.countVert = nansum(Vertone,3);
V.countBed = nansum(Bedone,3);

V.countBack(V.countBack==0)=NaN;
V.countMag(V.countMag==0)=NaN;
V.countVert(V.countVert==0)=NaN;
V.countBed(V.countBed==0)=NaN;

% Average mapped mean cross-sections from individual transects together
V.mcsBack = nanmean(Back,3);
%V.mcsDir = nanmean(Dir,3);  % Will not average correctly in all cases due to 0-360
%wrapping (PRJ, 9-29-10)
%V.mcsMag = nanmean(Mag,3);  %Mag recomputed from north, east, up components(PRJ, 3-21-11)
V.mcsEast = nanmean(East,3);
V.mcsNorth = nanmean(North,3);
V.mcsVert = nanmean(Vert,3);

%Average Magnitude
V.mcsMag = sqrt(V.mcsEast.^2 + V.mcsNorth.^2 + V.mcsVert.^2);

%Average the flow direction
V.mcsDir = ari2geodeg((atan2(V.mcsNorth, V.mcsEast))*180/pi);
% V.mcsDir = 90 - (atan2(V.mcsNorth, V.mcsEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
% qindx = find(V.mcsDir < 0);
%     if ~isempty(qindx)
%         V.mcsDir(qindx) = V.mcsDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
%     end

V.mcsBed = nanmean(Bed,3);

%Compute the Bed Elevation in meters (Takes the mean value of the entered
%WSE timeseries if file loaded)
disp(['Assigned Water Surface Elevation (WSE; in meters) = ' num2str(mean(A(1).wse))])
V.mcsBedElev = mean(A(1).wse) - V.mcsBed;

return

% Remove values (Omitted 11/23/10, PRJ)

V.mcsBack(:,1:J(1)-1)=NaN;
V.mcsBack(:,J(end)+1:end)=NaN;
V.mcsDir(:,1:J(1)-1)=NaN;
V.mcsDir(:,J(end)+1:end)=NaN;
V.mcsMag(:,1:J(1)-1)=NaN;
V.mcsMag(:,J(end)+1:end)=NaN;
V.mcsEast(:,1:J(1)-1)=NaN;
V.mcsEast(:,J(end)+1:end)=NaN;
V.mcsNorth(:,1:J(1)-1)=NaN;
V.mcsNorth(:,J(end)+1:end)=NaN;
V.mcsVert(:,1:J(1)-1)=NaN;
V.mcsVert(:,J(end)+1:end)=NaN;
V.mcsBed(:,1:J(1)-1)=NaN;
V.mcsBed(:,J(end)+1:end)=NaN;

V.countBack(:,1:J(1)-1)=NaN;
V.countMag(:,1:J(1)-1)=NaN;
V.countVert(:,1:J(1)-1)=NaN;
V.countBed(:,1:J(1)-1)=NaN;
V.countBack(:,J(end)+1:end)=NaN;
V.countMag(:,J(end)+1:end)=NaN;
V.countVert(:,J(end)+1:end)=NaN;
V.countBed(:,J(end)+1:end)=NaN;


