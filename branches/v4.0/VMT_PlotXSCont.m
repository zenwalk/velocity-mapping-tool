function [z,A,V,zmin,zmax] = VMT_PlotXSCont(z,A,V,var,exag,zerosecq)

%This function plots contours for the variable 'var' within the
%mean cross section given by the structure V. IF data is not supplied, user
%will be prompted to load data (browse to data).


%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-10-08 



disp(['Plotting Mean Cross Section Contour Plot: ' var])

%% User Input

%exag=50;    %Vertical exaggeration


%% Load the data if not supplied
if isempty(z) & isempty(A) & isempty(V) 
    [zPathName,zFileName,zf] = VMT_SelectFiles;  %Have the user select the preprocessed input files
    eval(['load ' zPathName '\' zFileName{1}]);
end


%% Plot contours

clvls = 60;

%Find the direction of primary discharge (flip if necessary)
binwidth  = diff(V.mcsDist,1,2);
binwidth  = horzcat(binwidth(:,1), binwidth);
binheight = diff(V.mcsDepth,1,1);
binheight = vertcat(binheight, binheight(1,:));
flux = nansum(nansum(V.u./100.*binwidth.*binheight)); %Not a true measured discharge because of averaging, smoothing, etc. but close 

% if zerosecq
%     pdmin = nanmin(nanmin(V.vp));
%     pdmax = nanmax(nanmax(V.vp));
% else
%     pdmin = nanmin(nanmin(V.u));
%     pdmax = nanmax(nanmax(V.u));
% end 
if flux < 0; %abs(pdmin) > abs(pdmax)
    flipxs = 1;
else
    flipxs = 0;
end

switch var
    case{'primary'}  %Plots the primary velocity
        if flipxs
            if zerosecq
                wtp=['-V.vp'];
                zmin=floor(nanmin(nanmin(-V.vp)));
                zmax=ceil(nanmax(nanmax(-V.vp)));
            else
                wtp=['-V.u'];
                zmin=floor(nanmin(nanmin(-V.u)));
                zmax=ceil(nanmax(nanmax(-V.u)));
            end
        else
            if zerosecq
                wtp=['V.vp'];
                zmin=floor(nanmin(nanmin(V.vp)));
                zmax=ceil(nanmax(nanmax(V.vp)));
            else
                wtp=['V.u'];
                zmin=floor(nanmin(nanmin(V.u)));
                zmax=ceil(nanmax(nanmax(V.u)));
            end
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;                  
    case{'secondary'} %Plots the secondary velocity
        if zerosecq
            wtp=['V.vs'];
            zmax=ceil(max(abs(nanmin(nanmin(V.vs))),abs(nanmax(nanmax(V.vs)))));
        else
            wtp=['V.v'];
            zmax=ceil(max(abs(nanmin(nanmin(V.v))),abs(nanmax(nanmax(V.v)))));
        end
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vertical'} %Plots the vertical velocity
        wtp=['V.w'];
        zmax=ceil(max(abs(nanmin(nanmin(V.w))),abs(nanmax(nanmax(V.w)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'backscatter'} %Plots the backscatter
        wtp=['V.mcsBack'];
        zmin=floor(nanmin(nanmin(V.mcsBack)));
        zmax=ceil(nanmax(nanmax(V.mcsBack)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'mag'} %Plots the velocity magnitude
        wtp=['V.mcsMag'];
        zmin=floor(nanmin(nanmin(V.mcsMag)));
        zmax=ceil(nanmax(nanmax(V.mcsMag)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'dirdevp'} %Plots the directional deviation from the primary velocity
        wtp=['V.mcsDirDevp'];
        %zmax=ceil(max(abs(nanmin(nanmin(V.mcsDirDevp))),abs(nanmax(nanmax(V.mcsDirDevp)))));
        %zmin=-zmax;
        zmin=floor(nanmin(nanmin(V.mcsDirDevp)));
        zmax=ceil(nanmax(nanmax(V.mcsDirDevp)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
end

        
figure(3); clf
pcolor(V.mcsDist,V.mcsDepth,eval(wtp(1,:)))
% contour(V.mcsDist,V.mcsDepth,eval(wtp(1,:)),zlevs,'Fill','on','Linestyle','none'); hold on
plot(V.mcsDist(1,:),V.mcsBed,'w','LineWidth',2); hold on

switch var
    case{'primary'}
        title('Streamwise (Primary) Velocity (cm/s)')
    case{'secondary'}
        title('Transverse (Secondary) Velocity (cm/s)')
    case{'vertical'}
        title('Vertical Velocity (cm/s)')
    case{'backscatter'}
        title('Backscatter Intensity (dB)')
    case{'mag'}
        title('Velocity Magnitude (Primary and Secondary) (cm/s)')
    case{'dirdevp'}
        title('Deviation from Primary Flow Direction (deg)')
end
hdl = colorbar; hold all
caxis([zmin zmax])
xlim([nanmin(nanmin(V.mcsDist)) nanmax(nanmax(V.mcsDist))])
ylim([0 max(V.mcsBed)])
set(gca,'YDir','reverse')
if flipxs
    set(gca,'XDir','reverse')
end
ylabel('Depth (m)','Color','w')
xlabel('Distance (m)','Color','w')
set(gca,'DataAspectRatio',[exag 1 1],'PlotBoxAspectRatio',[exag 1 1])
%set(gcf,'Color','k');
set(gca,'FontSize',14)
set(get(gca,'Title'),'FontSize',14,'Color','w') 
%set(gca,'Color','k')
set(gca,'XColor','w')
set(gca,'YColor','w')
set(gca,'ZColor','w')
set(gcf,'InvertHardCopy','off')
set(gcf,'Color',[0.2 0.2 0.2])
set(gca,'Color',[0.3 0.3 0.3])



