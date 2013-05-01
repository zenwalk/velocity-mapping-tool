function [z,A,V] = VMT_PlotXSContQuiverV3(z,A,V,var,sf,exag,qspchorz,qspcvert,secvecvar,vvelcomp)

%This function plots the the contour plot (mean XS) for the variable 'var'
%and then plots quivers with secondary flow (vertical and transverse
%components) on top of the contour plot.  IF data is not supplied, user
%will be prompted to load data (browse to data).

%V2 adds a vertical quiver spacing input

%V3 adds Rozovskii definitions 8/31/09

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-10-08 


%% Plot the contour plot
if isempty(z) & isempty(A) & isempty(V)
    [z,A,V,zmin,zmax] = VMT_PlotXSContV2([],[],[],var,exag);
else
    [z,A,V,zmin,zmax] = VMT_PlotXSContV2(z,A,V,var,exag);
end

if vvelcomp
    disp(['Plotting Secondary Flow Vector Field: ' secvecvar ' (with vertical velocity component)'])
else
    disp(['Plotting Secondary Flow Vector Field: ' secvecvar ' (without vertical velocity component)'])
end
%% Plot the secondary flow quivers

%User input 

clvls = 60;
%sf=3;       %Scale factor
%exag=50;    %Vertical exaggeration
%qspchorz=20;   %Vector spacing in # of ensembles

% Misc computations
if 0 %A(1).Sup.binSize_cm == 25  %Changed some stuff below--not sure of the reason this 25 cm binsize is singled out  PRJ  (singled out due to vertical velocity bias--omit for now)
    [I,J] = ind2sub(size(V.vp(2,:)),find(~isnan(V.vp(2,:))==1));  % Use row 2 because all row 1 values are nans (WHY???--set to zero for ringing?)
    et = J(1):qspchorz:J(end);
    [r c]=size(V.vp);
    bi = 1:2:r;  %8:4:r;
else
    [I,J] = ind2sub(size(V.vp(1,:)),find(~isnan(V.vp(1,:))==1));
    et = J(1):qspchorz:J(end);
    [r c]=size(V.vp);
    bi = 1:qspcvert:r;
end

%zmin = floor(nanmin(nanmin(V.vp))); 
%zmax = ceil(nanmax(nanmax(V.vp)));
%zinc = (zmax - zmin) / clvls;
%zlevs = zmin:zinc:zmax;

%Set the vertical velocity component
if vvelcomp  %include vertical velocity compoent in vector?
    vertcomp = V.wSmooth;
else
    vertcomp = zeros(size(V.wSmooth));
end

figure(3); hold all
%quiver(V.mcsDist(bi,et),V.mcsDepth(bi,et),-sf.*V.vsSmooth(bi,et),-sf.*V.wSmooth(bi,et),0,'k')
switch secvecvar
    case{'transverse'}  %uses secondary velocity computed in the plane of the mean cross section (i.e. transverse)
        vr = sqrt(abs((-sf.*V.vSmooth(bi,et)).^2 + (-sf./exag.*vertcomp(bi,et)).^2));
    case{'secondary_zsd'} %Uses secondary velocity computed with a zero secondary discharge
        vr = sqrt(abs((-sf.*V.vsSmooth(bi,et)).^2 + (-sf./exag.*vertcomp(bi,et)).^2));
    case{'secondary_roz'}
        vr = sqrt(abs((-sf.*V.Roz.usSmooth(bi,et)).^2 + (-sf./exag.*vertcomp(bi,et)).^2));
    case{'secondary_roz_y'}
        vr = sqrt(abs((-sf.*V.Roz.usySmooth(bi,et)).^2 + (-sf./exag.*vertcomp(bi,et)).^2));
    case{'primary_roz_y'}
        vr = sqrt(abs((-sf.*V.Roz.upySmooth(bi,et)).^2 + (-sf./exag.*vertcomp(bi,et)).^2));
end
        
%vr=sqrt(abs(-sf.*V.vsSmooth(bi,et).^2+-sf./exag.*V.wSmooth(bi,et).^2));
[rw cl] = size(V.mcsDist(bi,et));
toquiv(:,1) = reshape(V.mcsDist(bi,et),rw*cl,1);
toquiv(:,2) = reshape(V.mcsDepth(bi,et),rw*cl,1);
switch secvecvar
    case{'transverse'}
        toquiv(:,3) = reshape(-sf.*V.vSmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(V.vSmooth(bi,et))));
        %meansecvec = mean(mean(V.vSmooth(bi,et)));
    case{'secondary_zsd'}
        toquiv(:,3) = reshape(-sf.*V.vsSmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(V.vsSmooth(bi,et))));
        %meansecvec = mean(mean(V.vsSmooth(bi,et)));
    case{'secondary_roz'}
        toquiv(:,3) = reshape(-sf.*V.Roz.usSmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(V.Roz.usSmooth(bi,et))));
        %meansecvec = mean(mean(V.Roz.us(bi,et)));
    case{'secondary_roz_y'}
        toquiv(:,3) = reshape(-sf.*V.Roz.usySmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(V.Roz.usySmooth(bi,et))));
        %meansecvec = mean(mean(V.Roz.usy(bi,et)));
    case{'primary_roz_y'}
        toquiv(:,3) = reshape(-sf.*V.Roz.upySmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(V.Roz.upySmooth(bi,et))));
        %meansecvec = mean(mean(V.Roz.upy(bi,et))));
end
toquiv(:,4) = reshape(-sf./exag.*vertcomp(bi,et),rw*cl,1);  %Add negative sign to account for flipped vertical axes
toquiv(:,5) = reshape(vr,rw*cl,1);
%Ref arrow
x1 = 0.06*max(max(V.mcsDist));
x2 = 0.95*max(max(V.mcsBed));
x3=sf.*refvel; %Set to rounded max secondary velocity 
x4=0;
x5=x3;
toquiv(end+1,1) = x1;
toquiv(end,2) = x2;
toquiv(end,3) = x3;
toquiv(end,4) = x4;
toquiv(end,5) = x5;
%quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),sf); hold on
hh = quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,toquiv(:,5),exag);
plot(V.mcsDist(1,:),V.mcsBed,'w', 'LineWidth',2); hold on
ylim([0 max(V.mcsBed)])
caxis([zmin zmax]) %Reset the color bar to match that in the original contour plot
switch var        
    case{'streamwise'}
        title({'Streamwise Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'transverse'}
        title({'Transverse Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'vertical'}
        title({'Vertical Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'mag'}
        title({'Velocity Magnitude (Streamwise and Transverse) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'primary_zsd'}
        title({'Primary Velocity (Zero Secondary Discharge Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'secondary_zsd'}
        title({'Secondary Velocity (Zero Secondary Discharge Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'primary_roz'}
        title({'Primary Velocity (Rozovskii Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'secondary_roz'}
        title({'Secondary Velocity (Rozovskii Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')   
    case{'primary_roz_x'}
        title({'Primary Velocity (Rozovskii Definition; Downstream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')    
    case{'primary_roz_y'}
        title({'Primary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')        
    case{'secondary_roz_x'}
        title({'Secondary Velocity (Rozovskii Definition; Downstream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')        
    case{'secondary_roz_y'}
        title({'Secondary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')         
    case{'backscatter'}
        title({'Backscatter Intensity (dB)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
    case{'flowangle'}
        title({'Flow Direction (deg)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none')
end

ylabel('Depth (m)')
xlabel('Distance (m)')
set(gca,'DataAspectRatio',[exag 1 1],'PlotBoxAspectRatio',[exag 1 1])
%set(gcf,'Color','k');
set(gca,'FontSize',14)
set(get(gca,'Title'),'FontSize',14,'Color','w') 
%set(gca,'Color','k')
set(gca,'XColor','w')
set(gca,'YColor','w')
set(gca,'ZColor','w')
set(gcf,'InvertHardCopy','off')
set(gcf,'Color','k') %[0.2 0.2 0.2]
set(gca,'Color',[0.3 0.3 0.3])

text(0.06*max(max(V.mcsDist)), 0.90*max(max(V.mcsBed)),[num2str(refvel) ' cm/s'],'FontSize',12,'Color','w')

% scrsz = get(0,'ScreenSize');
% figure('OuterPosition',[1 scrsz(4) scrsz(3) scrsz(4)])

%Display the ratio of the mean secondary and primary velocity magnitudes 
spratio_zsd = nanmedian(nanmedian(abs(V.vs)))./nanmedian(nanmedian(abs(V.vp)));
spratio_roz = nanmedian(nanmedian(abs(V.Roz.usy)))./nanmedian(nanmedian(abs(V.Roz.up)));
disp(['Ratio of median Secondary to median Primary Velocity (zsd) = ' num2str(spratio_zsd)])
disp(['Ratio of median Secondary to median Primary Velocity (roz) = ' num2str(spratio_roz)])

return


%Add labels to the reference arrow and colorbar
text(50,12,['Vertical Distances Exaggerated by ',num2str(exag)],'FontSize',16)
text(140,17,'10 cm/s','FontSize',16)
