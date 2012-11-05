function ASCII2KML
% WinRiver ASCII to Google Earth KML 

% This program reads in an ASCII file or files generated from WinRiver 
% Classic ASCII output and outputs the GPS position into a KML file which
% can be displayed in Google Earth.
%
%(adapted from code by J. Czuba)

% P.R. Jackson 9/4/09

%% Read and Convert the Data

% Determine Files to Process
% Prompt user for directory containing files
defaultpath = 'C:\';
ascii2kmlpath = [];
if exist('VMT\LastDir.mat') == 2
    load('VMT\LastDir.mat');
    if exist(ascii2kmlpath) == 7
        ascii2kmlpath = uigetdir(ascii2kmlpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    else
        ascii2kmlpath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    end
else
    ascii2kmlpath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
end
zPathName = ascii2kmlpath;
Files = dir(zPathName);
allFiles = {Files.name};
filefind = strfind(allFiles,'ASC.TXT')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

if isempty(files)
    errordlg(['No ASC.TXT files found in ' ascii2kmlpath '.  Ensure data files are in the form "*_ASC.TXT" (Standard WRII naming convention).']);
end

% Allow user to select which files are to be processed
selection = listdlg('ListSize',[300 300],'ListString', files,'Name','Select Data Files');
zFileName = files(selection);

% Determine number of files to be processed
if  isa(zFileName,'cell')
    z=size(zFileName,2);
    zFileName=sort(zFileName);       
else
    z=1;
    zFileName={zFileName}
end
%msgbox('Loading Data...Please Be Patient','Conversion Status','help','replace');
% Read in Selected Files
% % Initialize row counter
% j=0;
% st=['A'; 'B'; 'C'; 'D'; 'E'; 'F'];
% Begin master loop

wbh = waitbar(0,'Writing KML Files...Please Be Patient');
for zi=1:z
    % Open txt data file
    if  isa(zFileName,'cell')
        fileName=strcat(zPathName,'\',zFileName(zi));
        fileName=char(fileName);
    else
        fileName=strcat(zPathName,zFileName);
    end

    % screenData 0 leaves bad data as -32768, 1 converts to NaN
    screenData=1;

    % tfile reads the data from an RDI ASCII output file and puts the
    % data in a Matlab data structure with major groups of:
    % Sup - supporing data
    % Wat - water data
    % Nav - navigation data including GPS.
    % Sensor - Sensor data
    % Q - discharge related data
    ignoreBS = 0;
    [A(zi)]=tfile(fileName,screenData,ignoreBS);
    %Extract only Lat lon data
    latlon(:,1)=A(zi).Nav.lat_deg(:,:);
    latlon(:,2)=A(zi).Nav.long_deg(:,:);
    
    %Rescreen data to remove missing data (30000 value)
    indx1 = find(abs(latlon(:,1)) > 90);
    indx2 = find(abs(latlon(:,2)) > 180);
    latlon(indx1,1)=NaN;
    latlon(indx2,2)=NaN;
    
    indx3 = find(~isnan(latlon(:,1)) & ~isnan(latlon(:,2)));
    latlon = latlon(indx3,:); 
    
    clear A
    
    % Determine the file name
    idx=strfind(fileName,'.');
    namecut = fileName(1:idx(end)-5);
    
    % Write latitude and longitude into a KML file
    %msgbox('Writing KML Files...','Conversion Status','help','replace');
    pwr_kml(namecut,latlon);
    
    clear latlon idx namecut 
    waitbar(zi/z); %update the waitbar
end
delete(wbh) %remove the waitbar
msgbox('Conversion Complete','Conversion Status','help','replace');

% Save the paths
if exist('LastDir.mat') == 2
    save('LastDir.mat','ascii2kmlpath','-append')
else
    save('LastDir.mat','ascii2kmlpath')
end

%%
function pwr_kml(name,latlon)
%makes a kml file for use in google earth
%input:  name of track, one matrix containing latitude and longitude
%usage:  pwr_kml('track5',latlon)

header=['<kml xmlns="http://earth.google.com/kml/2.0"><Placemark><description>"' name '"</description><LineString><tessellate>1</tessellate><coordinates>'];
footer='</coordinates></LineString></Placemark></kml>';

fid = fopen([name 'ShipTrack.kml'], 'wt');
d=flipud(rot90(fliplr(latlon)));
fprintf(fid, '%s \n',header);
fprintf(fid, '%.6f,%.6f,0.0 \n', d);
fprintf(fid, '%s', footer);
fclose(fid);

