function VMT_PlotPlanViewQuiversASCv2(z,A,V,Map,drng,ascale,QuiverSpacing,pvsmwin,pshore)

%This function plots a plan view of the measurement region with a vector field of
%depth averaged velocity for each processed mean cross section.

%ASC version is for plotting ASCII loaded data. 9/2/09 (also has new
%pvsmwin input for the filter window)

%User Notes:

%1. Supply z, A, V, and Map for plotting a single mean cross section
%2. Leave z, A, V, and Map blank (i.e. [],[],[],[]) to load multiple,
%   (preprocessed and saved) cross section.  The user will be prompted to load
%   the files and load the Map file.
%3. Leave drng blank (i.e. []) for full depth means or specify
%   the a 2 component vector of depths in meters (drng = [ dupper dlower]) of the 
%   depth range to average and plot


%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-10-08 

%v2 Adds DOQQ plotting capabilities (PRJ, 6-23-10)

warning off
disp('Plotting Plan View with Depth-Averaged Velocity Vectors...')

%% User Input

%QuiverSpacing   = 15;  %Plots a quiver every X emsembles
%ascale          = 1.5; %Set to 1 for autoscaling and other values for increased or decreased arrow lengths

%% Plot Quivers on Area Map

if isnan(drng)
    drng = [];
end

windowSize      = pvsmwin; %Size of window for running average in smoothing of mean vel vectors (set in GUI)

figure(2); clf

if isempty(z) & isempty(A) & isempty(V) & isempty(Map)
    mapmult = 1;
    [zPathName,zFileName,zf] = VMT_SelectFiles;  %Have the user select the preprocessed input files
else
    mapmult = 0;
    zf = 1;  %Plot only a single cross section
end

for n=1:zf
    if mapmult
        eval(['load ' zPathName '\' zFileName{n}]);
    end
    
    if ~isempty(drng)
        indx = find(V.mcsDepth(:,1) < drng(1) | V.mcsDepth(:,1) > drng(2));
        
        %Set all data outside depth range to nan
        V.mcsX(indx,:) = nan;
        V.mcsY(indx,:) = nan;
        V.mcsEast(indx,:) = nan;
        V.mcsNorth(indx,:) = nan;
        
        if n == 1
            disp(['Plotting Depth Range ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm'])
        end
        
        clear indx
    end
    
   %Compute mean positions
   V.mcsX1 = nanmean(V.mcsX,1);
   V.mcsY1 = nanmean(V.mcsY,1);
    
   if 0; %Compute the depth averaged velocity (straight arithmetic mean--old method)
        V.mcsEast1 = nanmean(V.mcsEast,1);
        V.mcsNorth1 = nanmean(V.mcsNorth,1);
    
   else %Compute the depth (or layer) averaged velocity (new method)
        V.mcsEast1  = VMT_LayerAveMean(V.mcsDepth,V.mcsEast);
        V.mcsNorth1 = VMT_LayerAveMean(V.mcsDepth,V.mcsNorth);
   end
    

    %Smooth using a running mean defined by WindowSize (averages
    %'2*windowsize+1' ensembles together (centered on node (boxcar filter))
    if windowSize == 0
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
        V.mcsEast1sm  = V.mcsEast1;
        V.mcsNorth1sm = V.mcsNorth1;
    else
%         V.mcsX1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsX1);
%         V.mcsY1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsY1);
%         V.mcsEast1sm  = filter(ones(1,windowSize)/windowSize,1,V.mcsEast1);
%         V.mcsNorth1sm = filter(ones(1,windowSize)/windowSize,1,V.mcsNorth1);
        
        V.mcsEast1sm  = nanmoving_average(V.mcsEast1,windowSize);  %added 1-7-10, prj
        V.mcsNorth1sm = nanmoving_average(V.mcsNorth1,windowSize);
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
    end
    
    for zi = 1 : z
        Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
    end
    numavg = nansum(~isnan(Mag),3);
    numavg(numavg==0) = NaN;
    enscnt = nanmean(numavg,1);
    [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to 1 from 2 (PRJ, 12-12-08)

    et = windowSize+J(1):QuiverSpacing:J(end);  
    
    % M(2*n-1,1)=V.mcsX(1,1);
    % M(2*n,1)=V.mcsX(1,end);
    % M(2*n-1,2)=V.mcsY(1,1);
    % M(2*n,2)=V.mcsY(1,end);
    %
    % idx=strfind(zFileName{n},'.');
    % namecut=zFileName{1,n}(2:idx(1)-1);
    %
    % pwr_kml(namecut,latlon);
    
    if n == 1
        toquiv(1:493,1:4)=NaN;
        lenp = 0;
    end
    
    len = length(V.mcsX1sm(1,et));

    toquiv(lenp+1:len+lenp,1)=V.mcsX1sm(1,et);
    toquiv(lenp+1:len+lenp,2)=V.mcsY1sm(1,et);
    toquiv(lenp+1:len+lenp,3)=nanmean(V.mcsEast1sm(:,et),1);
    toquiv(lenp+1:len+lenp,4)=nanmean(V.mcsNorth1sm(:,et),1);

    lenp = length(V.mcsX1sm(1,et))+lenp;

    % quiverc2wcmap(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0);
    %quiverc(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    %     quiver(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    
    if mapmult
        clear A V z Mag numavg enscnt I J latlon idx namecut
    end
end
vr = sqrt(toquiv(:,3).^2+toquiv(:,4).^2);
figure(2); hold on
% if pdoqq
%     VMT_OverlayDOQQ
% end
if pshore
    if ~isempty(Map) 
        VMT_PlotShoreline(Map)
    end
end
%quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,vr,1);
quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),ascale);
colorbar('FontSize',16,'XColor','w','YColor','w');
if sum(~isnan(vr)) == 0
    errordlg('No Data in Specified Depth Range','Plotting Error');
end
caxis([nanmin(vr) nanmax(vr)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
if ~isempty(drng)
    title({'Depth-Averaged Velocities (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w');
else
    title('Depth-Averaged Velocities (cm/s)','Color','w');
end

xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
figure(2); box on
set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
%set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
set(gca,'TickDir','out')

% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');

function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 
