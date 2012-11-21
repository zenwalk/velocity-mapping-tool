function [A,V] = VMT_MapEns2MeanXSV2(z,A,setends)

%This routine fits multiple transects at a single location with a single
%line and maps individual ensembles to this line. Inputs are number of files (z) and data matrix (Z)(see ReadFiles.m).
%Output is the updated data matrix with new mapped variables. 

%V2 adds the capability to set the endpoints of the mean cross section

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 



%% Determine the best fit mean cross-section line from multiple transects
% initialize vectors for concatenation

x = [];
y = [];
figure(1); clf
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
for zi = 1 : z
    
    % concatenate coords into a single column vector for regression
    x=cat(1,x,A(zi).Comp.xUTM);
    y=cat(1,y,A(zi).Comp.yUTM);

    figure(1); hold on
    %plot(A(zi).Comp.xUTM,A(zi).Comp.yUTM,'r'); hold on
    plot(A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b'); hold on
    
    %Find the mean east and north velocity for eact transect (for mean flow
    %direction)
    mVe(zi) = nanmean(nanmean(A(zi).Clean.vEast,1));
    mVn(zi) = nanmean(nanmean(A(zi).Clean.vNorth,1));
              
end

if setends  %Gets a user text file with fixed cross section end points 
    
        defaultpath = 'C:\';
        endspath = [];
        if exist('VMT\LastDir.mat') == 2
            load('VMT\LastDir.mat');
            if exist(endspath) == 7
                [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',endspath);       
            else
                [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',defaultpath);
            end
        else
            [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',defaultpath);
        end
        infile = [endspath file];
        %[file,path] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File');
        %infile = [path file];
        disp('Loading Endpoint File...' );
        disp(infile);
        data = dlmread(infile);
        x = data(:,1);
        y = data(:,2);
        figure(1); hold on
        plot(x,y,'go','MarkerSize',10); hold on
end

% Compute the mean flow direction for all the transects in geographic angle
mfdVe = mean(mVe);  %Mean east velocity for all the transects
mfdVn = mean(mVn);  %Mean north velocity for all the transects
V.mfd = ari2geodeg((atan2(mfdVn, mfdVe))*180/pi);  % Mean flow direction in geographic angle

% find the equation of the best fit line
xw = min(x); xe = max(x);
ys = min(y); yn = max(y);
xrng = xe - xw;
yrng = yn - ys;

if xrng >= yrng %Fit based on coordinate with larger range of values (original fitting has issues with N-S lines because of repeated X values), PRJ 12-12-08
    [P,S] = polyfit(x,y,1);
    figure(1); hold on; 
    plot(x,polyval(P,x),'g-')
    V.m = P(1);
    V.b = P(2);
    dx = xe-xw;
    dy = polyval(P,xe)-polyval(P,xw);
else
    [P,S] = polyfit(y,x,1);
    figure(1); hold on; 
    plot(polyval(P,y),y,'g-')
    V.m = 1/P(1);           %Reformat slope and intercept in terms of y= fn(x) rather than x = fn(y)
    V.b = -P(2)/P(1);
    dx = polyval(P,yn)-polyval(P,ys);
    dy = yn-ys;
%     if V.m >= 0
%         dy = yn-ys;
%     elseif V.m < 0
%         dy = ys-yn;
%     end
end

% Determine the distance between the mean cross-section
% endpoints
dl = sqrt(dx^2+dy^2);

% Compute the angle of the MCS in geographic angle
if V.m >= 0
    V.theta = ari2geodeg(atand(V.m)); 
elseif V.m < 0
    V.theta = ari2geodeg(atand(V.m));
end

% Determine the direction of the streamwise coordinate, which
% is taken as perpendicular to the mean cross section. Theta is
% expressed in geographical (N = 0 deg, clockwise positive)
% coordinates. This method uses a vector based approach which
% is insensitive to orientation of the cross section.

% First compute the normal unit vector to the mean
% cross section
N = [-dy/sqrt(dx^2+dy^2)...
    dx/sqrt(dx^2+dy^2)];

% Compute the mean flow direction in the cross section. To do
% this, we also have to convert from geographic angle to
% arimetic angle
arimfddeg = geo2arideg(V.mfd);
[xmfd,ymfd] = pol2cart(arimfddeg*pi/180,1);
M = [xmfd ymfd];

% Now compute the angle between the normal and mean flow
% direction unit vectors
vdif = acos(dot(N,M)/(norm(N)*norm(M)))*180/pi;

% If the angle is greater than 90 degs, the normal vector needs
% to be reversed before resolving the u,v coordinates
if vdif >= 90
    N = -N;
end

% Plot N and M to check (scale of the vectors is 10% of the
% total length of the cross section)
midy = ys+abs(yrng)/2;
midx = xw+xrng/2;
figure(1); hold on;
quiver(...
    midx,midy,N(1)*dl*0.1,...
    N(2)*dl*0.1,1,'k')
quiver(...
    midx,midy,M(1)*dl*0.1,...
    M(2)*dl*0.1,1,'r')

% Geographic angle of the normal vector to the cross section
V.phi = ari2geodeg(cart2pol(N(1),N(2))*180/pi);

%Former method commented out
% whichstats = {'tstat','yhat'};
% stats = regstats(y,x,'linear', whichstats);
% 
% % mean cross-section line slope and intercept
% V.m = stats.tstat.beta(2);
% V.b = stats.tstat.beta(1);

clear x y stats whichstats zi

%% Map ensembles to mean c-s line
% Determine the point (mapped ensemble point) where the equation of the 
% mean cross-section line intercepts a line perpendicular to the mean
% cross-section line passing through an ensemble from an individual
% transect (see notes for equation derivation)

for zi = 1 : z
    
    A(zi).Comp.xm = ((A(zi).Comp.xUTM-V.m.*V.b+V.m.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));
    A(zi).Comp.ym = ((V.b+V.m.*A(zi).Comp.xUTM+V.m.^2.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));

    %A(zi).Comp.h1 = nanmean(A(zi).Nav.depth,2)';
end


%Plot data to check
xensall = [];
yensall = [];
for zi = 1 : z
  plot(A(zi).Comp.xm,A(zi).Comp.ym,'b.')
  xensall = [xensall; A(zi).Comp.xm];
  yensall = [yensall; A(zi).Comp.ym];
end
% plot(A(3).Comp.xm,A(3).Comp.ym,'xg')
% plot(A(4).Comp.xm,A(4).Comp.ym,'oy')
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
box on
grid on
%Plot a legend in Figure 1
%figure(1); hold on
%legend('Shoreline','GPS(corr)','GPS(raw)','Best Fit','Trans 1
%(mapped)','Other Trans (mapped)')

%Compute the median distance between mapped points
Dmat = [xensall yensall];
if xrng > yrng
    Dmat = sortrows(Dmat,1);
else
    Dmat = sortrows(Dmat,2);
end
dxall = diff(Dmat(:,1));
dyall = diff(Dmat(:,2));
densall = sqrt(dxall.^2 + dyall.^2);
V.meddens = median(densall);
V.stddens = std(densall);
% disp(['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'])
% disp(['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'])
% disp(['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m'])

%Display in message box for compiled version
msg_string = {['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'],...
    ['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'],...
    ['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m']};
msgbox(msg_string,'VMT Grid Node Spacing','help','replace');

%%Save the shorepath
if setends
    if exist('LastDir.mat') == 2
        save('LastDir.mat','endspath','-append')
    else
        save('LastDir.mat','endspath')
    end
end

