function [zPathName,zFileName,savefile,A,z] = VMT_ReadFiles;

%This function reads in multiple ASCII output files from WR of WRII.

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-11-08 

%Added save path functionality (PRJ, 6-23-10)

%% Read in multiple ASCII .TXT Files
% This program reads in multiple ASCII text files into a single structure.

%% Determine Files to Process
% Prompt user for directory containing files
defaultpath = 'C:\';
asciipath = [];
if exist('VMT\LastDir.mat','file') == 2
    load('VMT\LastDir.mat');
    if exist(asciipath,'dir') == 7
        asciipath = uigetdir(asciipath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    else
        asciipath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    end
else
    asciipath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
end
zPathName = asciipath;
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
    errordlg(['No ASC.TXT files found in ' asciipath '.  Ensure data files are in the form "*_ASC.TXT" (Standard WRII naming convention).']);
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
msgbox('Loading Data...','VMT Status','help','replace');
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
    try
        [A(zi)]=tfile(fileName,screenData,ignoreBS);
        if 0 %troubleshooting 8-20-12 (PRJ)
            A(zi).Sup.intUnits = cellstr('dB');
            A(zi).Sup.vRef = cellstr('VTG');
            A(zi).Sup.units = cellstr('cm');
        end
        %[A(zi)]=tfile_opt(fileName,screenData);  %Implemented new
        %optimized tfile (PRJ 8-20-12) (Something weird is going on here,
        %don't use yet)
    catch err
        erstg = {'                                                      ',...
                 'An unknown error occurred when reading the ASCII file.',...
                 'Occasionally this occurs due to a corrupt ASCII file with',...
                 'formatting errors. Please regenerate the ASCII file and ',...
                 'retry loading into VMT. An error may also occur if there ',...
                 'are white spaces or special characters (e.g. *?<>|) in ',...
                 'the filenames or paths. Ensure no such spaces or ',...
                 'characters exist and try loading the files again.'};
        errordlg([zFileName(zi) erstg],'VMT Status','replace');
        rethrow(err)
        break
    end
    
    % Check the units to ensure they are metric
    
    if ~strcmp(A(zi).Sup.units,'cm')
        erstg = {'                                                      ',...
                 'Units in ASCII file are not metric.  VMT only accepts data'...
                 'in metric units.  Please change the units in WinRiver II'...
                 'and export your ASCII files again before reloading into VMT.'};
        errordlg([zFileName(zi) erstg],'VMT Status','replace');
        error('VMT:unitsChk', 'Input not in metic units')
    end

end

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

% Save the paths

if exist('LastDir.mat','file') == 2
    save('LastDir.mat','asciipath','-append')
else
    save('LastDir.mat','asciipath')
end


