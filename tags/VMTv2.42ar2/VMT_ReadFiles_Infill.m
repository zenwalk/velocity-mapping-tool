function [zPathName,zFileName,savefile,A,z] = VMT_ReadFiles_Infill;

%This function is identical to "VMT_ReadFiles.m", but it will infill
%missing data in the raw files due to sensor problems. The function is      
%dependent on a function "nan_interp". The original data is not altered-
%only the blanks are infilled.

% Last modified 7/6/2010 by Frank L. Engel

%This function reads in multiple ASCII output files from WR of WRII.

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-11-08 

%% Read in multiple ASCII .TXT Files
% This program reads in multiple ASCII text files into a single structure.

%% Determine Files to Process
% Prompt user for directory containing files
zPathName = uigetdir('','Select the Directory Containing ASCII Output Data Files (*.txt)');
Files = dir(zPathName);
allFiles = {Files.name};
filefind=strfind(allFiles,'ASC.TXT')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

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

%% Read in Selected Files
% Initialize row counter
j=0;
st=['A'; 'B'; 'C'; 'D'; 'E'; 'F'];
% Begin master loop
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

    
    % Infill missing bins using 2D Linear interpolation
 
    blank = A(zi).Sup.blank_cm / 100; % Reported blanking distance in meters
    
    % Fill in all NaNs by interpolation (function dependency "nan_interp")
    [A(zi).Wat.vDir]=nan_interp(A(zi).Wat.vDir,2); 
    [A(zi).Wat.vMag]=nan_interp(A(zi).Wat.vMag,2); 
    [A(zi).Wat.vEast]=nan_interp(A(zi).Wat.vEast,2); 
    [A(zi).Wat.vNorth]=nan_interp(A(zi).Wat.vNorth,2);
    [A(zi).Wat.vVert]=nan_interp(A(zi).Wat.vVert,2); 
    
    % Find bin nearest to the bed minus the blanking distance
    % and replace everything below the blanking distance with NaNs
    for i = 1:size(A(zi).Wat.binDepth,2)
            [min_difference(i), array_position(i)] = min(abs(A(zi).Wat.binDepth(:,i)...
                - nanmean(A(zi).Nav.depth(i,:) - blank)));
        A(zi).Wat.vDir(array_position(i):end,i) = NaN;
        A(zi).Wat.vMag(array_position(i):end,i) = NaN;
        A(zi).Wat.vEast(array_position(i):end,i) = NaN;
        A(zi).Wat.vNorth(array_position(i):end,i) = NaN;
        A(zi).Wat.vVert(array_position(i):end,i) = NaN;
    end

end

disp('NOTICE: You are interpolating for missing data, be sure to')
disp('     run without infilling first. Infilling is the last resort,')
disp('     and may not be appropriate for all data!!')
%% Save data returned by tfile to .mat with same prefix as ASCII 
%(saving now takes place after processing, but savefile is generated here)
idx=strfind(zFileName,'_');
namecut=zFileName{1}(1:idx{1}(end));
%numcut1=zFileName{1}(idx{1}(end)-3:idx{1}(end)-1);
numcut2=zFileName{z}(idx{z}(end)-3:idx{z}(end)-1);
[s,mess,messid] = mkdir([zPathName '\VMTProcFiles']); 
disp(mess)
%savefile=strcat(zPathName,'\VMTProcFiles\',namecut,'_',numcut1,'_',numcut2,'.mat');
savefile=strcat(zPathName,'\VMTProcFiles\',namecut,numcut2,'.mat');
%save(savefile, 'A','z')


