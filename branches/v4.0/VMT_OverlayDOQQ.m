function VMT_OverlayDOQQ

% Prompts the user for a geotiff DOQQ (USGS) and overlays the aerial image
% in the plan view vector plot.  User can select multiple files. 

% Currently only supports a geotiff in UTM corrdinates (USGS DOQQ for
% example) as the image is not projected and is plotted as XY data.  

%P.R. Jackson, USGS 6-14-10

%Added save path functionality (PRJ, 6-23-10)


%% Get the data file
%[file,path] = uigetfile({'*.tif','All TIF Files'; '*.*','All Files'},'Select DOQQ (GeoTIFF) File','F:\Data');
%infile{1} = [path file];

i = 1;
getdoqq = 'Yes';
doqqpath = [];
while strcmp(getdoqq, 'Yes');
    defaultpath = 'C:\';
    
    if i == 1
        if exist('VMT\LastDir.mat','file') == 2
            load('VMT\LastDir.mat');
            if exist(doqqpath,'dir') == 7
                [file,doqqpath] = uigetfile({'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},'Select Background File',doqqpath);
            else
                [file,doqqpath] = uigetfile({'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},'Select Background File',defaultpath);
            end
        else
            [file,doqqpath] = uigetfile({'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},'Select Background File',defaultpath);
        end
        infile{i} = [doqqpath file];
    else
        [file,doqqpath] = uigetfile({'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},'Select Background File',doqqpath);
        infile{i} = [doqqpath file];
    end
    
    options.Interpreter = 'tex';
    % Include the desired Default answer
    options.Default = 'No';
    % Create a TeX string for the question
    qstring = 'Do you want to load another background file?';
    getdoqq = questdlg(qstring,'Add Background',...
    'Yes','No',options);

    i = i+1;
    
end

if infile{1}(1) ==  0
    figure(2); hold on
    return
end

%% Save the path

if exist('LastDir.mat','file') == 2
    save('LastDir.mat','doqqpath','-append')
else
    save('LastDir.mat','doqqpath')
end

%% Plot the image
figure(2); hold on
for i = 1:length(infile);
    hdlmap = mapshow(infile{i}); hold on
    uistack(hdlmap,'bottom')
end

set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
axis image on
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
%set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
set(gca,'TickDir','out')
figure(2); box on

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

    
    
    
    