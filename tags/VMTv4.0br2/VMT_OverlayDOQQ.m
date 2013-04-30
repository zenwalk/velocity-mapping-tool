function log_text = VMT_OverlayDOQQ(pathname)
% Prompts the user for a geotiff DOQQ (USGS) and overlays the aerial image
% in the plan view vector plot.  User can select multiple files. 
%
% Currently only supports a geotiff in UTM corrdinates (USGS DOQQ for
% example) as the image is not projected and is plotted as XY data.  
%
% Added save path functionality (PRJ, 6-23-10)
%
% P.R. Jackson, USGS 6-14-10
% Last modified: F.L. Engel, USGS, 3/13/2013



%% Get the data file
%[file,path] = uigetfile({'*.tif','All TIF Files'; '*.*','All Files'},'Select DOQQ (GeoTIFF) File','F:\Data');
%infile{1} = [path file];

i = 1;
getdoqq = 'Yes';
doqqpath = pathname;
log_text = {''};
while strcmp(getdoqq, 'Yes');
    [file,doqqpath] = uigetfile({'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},'Select Background File',doqqpath);
        infile{i} = [doqqpath file];
 
    options.Interpreter = 'tex';
    % Include the desired Default answer
    options.Default = 'No';
    
    % Create a TeX string for the question
    if ~ischar(file) % User hit cancel, get out quick
        return
    else
        qstring = 'Do you want to load another background file?';
        getdoqq = questdlg(qstring,'Add Background',...
            'Yes','No',options);
    end
    i = i+1;
    
end


% See if PLOT 1 exists already, if not, make the figure
fig_planview_handle = findobj(0,'name','Plan View Map');
if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle);
else
    fig_planview_handle = figure('name','Plan View Map'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

if infile{1}(1) ==  0
    figure(fig_planview_handle); hold on
    return
end

%% Save the path
% if exist('LastDir.mat') == 2
    % save('LastDir.mat','doqqpath','-append')
% else
    % save('LastDir.mat','doqqpath')
% end

%% Plot the image

for i = 1:length(infile);
    hdlmap = mapshow(infile{i}); hold on
    uistack(hdlmap,'bottom')
end

log_text = vertcat({'Adding background image:'},infile);

set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
axis image on
% xlabel('UTM Easting (m)')
% ylabel('UTM Northing (m)')
% set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
%set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
% set(gca,'TickDir','out')
% figure(2); box on

% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');


%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

    
    
    
    