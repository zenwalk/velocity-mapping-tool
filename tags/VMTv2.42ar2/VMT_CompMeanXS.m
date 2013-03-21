function [A,V] = VMT_CompMeanXS(z,A,V)

%This routine computes the mean cross section data from individual transects 
%that have been previously mapped to a common grid. 

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 


%% Average mapped spatial averaged mean cross-sections from individual transects together 
% Assign mapped uniform grid vectors to the same array for averaging
for zi = 1 : z
    
    Back(:,:,zi) = A(zi).Comp.mcsBack(:,:);
    Dir(:,:,zi) = A(zi).Comp.mcsDir(:,:);
    Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
    East(:,:,zi) = A(zi).Comp.mcsEast(:,:);
    North(:,:,zi) = A(zi).Comp.mcsNorth(:,:);
    Vert(:,:,zi) = A(zi).Comp.mcsVert(:,:);
    Bed(:,:,zi) = A(zi).Comp.mcsBed(:,:);
    
    BackContrib(:,:,zi) = A(zi).Comp.mcsBackContrib(:,:);
    DirContrib(:,:,zi) = A(zi).Comp.mcsDirContrib(:,:);
    MagContrib(:,:,zi) = A(zi).Comp.mcsMagContrib(:,:);
    EastContrib(:,:,zi) = A(zi).Comp.mcsEastContrib(:,:);
    NorthContrib(:,:,zi) = A(zi).Comp.mcsNorthContrib(:,:);
    VertContrib(:,:,zi) = A(zi).Comp.mcsVertContrib(:,:);
    BedContrib(:,:,zi) = A(zi).Comp.mcsBedContrib(:,:);

end

% Average mapped mean cross-sections from individual transects together
V.mcsBack = nanmean(Back,3);
V.mcsDir = nanmean(Dir,3);
V.mcsMag = nanmean(Mag,3);
V.mcsEast = nanmean(East,3);
V.mcsNorth = nanmean(North,3);
V.mcsVert = nanmean(Vert,3);
V.mcsBed = nanmean(Bed,3);

% Count contribution per bin
V.mcsBackContrib = nansum(BackContrib,3);
V.mcsDirContrib = nansum(DirContrib,3);
V.mcsMagContrib = nansum(MagContrib,3);
V.mcsEastContrib = nansum(EastContrib,3);
V.mcsNorthContrib = nansum(NorthContrib,3);
V.mcsVertContrib = nansum(VertContrib,3);
V.mcsBedContrib = nansum(BedContrib,3);

%% Average mapped mean interpolated cross-sections from individual transects together 
% Assign mapped uniform grid vectors to the same array for averaging
for zi = 1 : z
    
    BackI(:,:,zi) = A(zi).Comp.mcsBackI(:,:);
    DirI(:,:,zi) = A(zi).Comp.mcsDirI(:,:);
    MagI(:,:,zi) = A(zi).Comp.mcsMagI(:,:);
    EastI(:,:,zi) = A(zi).Comp.mcsEastI(:,:);
    NorthI(:,:,zi) = A(zi).Comp.mcsNorthI(:,:);
    VertI(:,:,zi) = A(zi).Comp.mcsVertI(:,:);
    BedI(:,:,zi) = A(zi).Comp.mcsBedI(:,:);

end

numavg = nansum(~isnan(MagI),3);
numavg(numavg==0) = NaN;
enscnt = nanmean(numavg,1);
[I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to >= 1 PRJ 12-10-08  (uses data even if only one measurement)

BackoneI= BackI;
MagoneI = MagI;
VertoneI = VertI;
BedoneI = BedI;

BackoneI(~isnan(BackI))=1;
MagoneI(~isnan(MagI))=1;
VertoneI(~isnan(VertI))=1;
BedoneI(~isnan(BedI))=1;

V.countBackI = nansum(BackoneI,3);
V.countMagI = nansum(MagoneI,3);
V.countVertI = nansum(VertoneI,3);
V.countBedI = nansum(BedoneI,3);

V.countBackI(V.countBackI==0)=NaN;
V.countMagI(V.countMagI==0)=NaN;
V.countVertI(V.countVertI==0)=NaN;
V.countBedI(V.countBedI==0)=NaN;

% Average mapped mean cross-sections from individual transects together
% NOTE: If you remove these I's then the interpolated values will overwrite
% the values computed from the spatial average and be plotted in subsequent
% plots. This can be used to compare the two schemes.
V.mcsBackI = nanmean(BackI,3);
V.mcsDirI = nanmean(DirI,3);
V.mcsMagI = nanmean(MagI,3);
V.mcsEastI = nanmean(EastI,3);
V.mcsNorthI = nanmean(NorthI,3);
V.mcsVertI = nanmean(VertI,3);
V.mcsBedI = nanmean(BedI,3);

V.mcsBackI(:,1:J(1)-1)=NaN;
V.mcsBackI(:,J(end)+1:end)=NaN;
V.mcsDirI(:,1:J(1)-1)=NaN;
V.mcsDirI(:,J(end)+1:end)=NaN;
V.mcsMagI(:,1:J(1)-1)=NaN;
V.mcsMagI(:,J(end)+1:end)=NaN;
V.mcsEastI(:,1:J(1)-1)=NaN;
V.mcsEastI(:,J(end)+1:end)=NaN;
V.mcsNorthI(:,1:J(1)-1)=NaN;
V.mcsNorthI(:,J(end)+1:end)=NaN;
V.mcsVertI(:,1:J(1)-1)=NaN;
V.mcsVertI(:,J(end)+1:end)=NaN;
V.mcsBedI(:,1:J(1)-1)=NaN;
V.mcsBedI(:,J(end)+1:end)=NaN;

V.countBackI(:,1:J(1)-1)=NaN;
V.countMagI(:,1:J(1)-1)=NaN;
V.countVertI(:,1:J(1)-1)=NaN;
V.countBedI(:,1:J(1)-1)=NaN;
V.countBackI(:,J(end)+1:end)=NaN;
V.countMagI(:,J(end)+1:end)=NaN;
V.countVertI(:,J(end)+1:end)=NaN;
V.countBedI(:,J(end)+1:end)=NaN;

