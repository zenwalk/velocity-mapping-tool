function [zPathName,zFileName,savefile,A,z] = VMT_ReadFiles;

%This function reads in multiple ASCII output files from WR of WRII.

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-11-08 

%5-12-09 Added ability to read *n.000 files

%% Read in multiple ASCII .TXT Files
% This program reads in multiple ASCII text files into a single structure.

%% Determine Files to Process
% Prompt user for directory containing files
zPathName = uigetdir('','Select the Directory Containing ASCII Output Data Files (*.txt,*t.000)');
Files = dir(zPathName);
allFiles = {Files.name};
filefind1=strfind(allFiles,'ASC.TXT')';
filefind2=strfind(allFiles,'t.000')';
if ~isempty(filefind1)
    filefind = filefind1;
end
if ~isempty(filefind2)
    filefind = filefind2;
end
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
    % Q - discharge related dat
	ignoreBS = 0;
    [A(zi)]=tfile(fileName,screenData,ignoreBS);
    

end

%% Save data returned by tfile to .mat with same prefix as ASCII 
%(saving now takes place after processing, but savefile is generated here)
idx=strfind(zFileName,'_ASC.txt')
if isempty(idx)
    idx=strfind(zFileName,'t.000')
end
namecut=zFileName{1}(1:idx{1}(end));
%numcut1=zFileName{1}(idx{1}(end)-3:idx{1}(end)-1);
numcut2=zFileName{z}(idx{z}(end)-3:idx{z}(end)-1);
[s,mess,messid] = mkdir([zPathName '\VMTProcFiles']); 
disp(mess)
%savefile=strcat(zPathName,'\VMTProcFiles\',namecut,'_',numcut1,'_',numcut2,'.mat');
savefile=strcat(zPathName,'\VMTProcFiles\',namecut,numcut2,'.mat');
%save(savefile, 'A','z')


