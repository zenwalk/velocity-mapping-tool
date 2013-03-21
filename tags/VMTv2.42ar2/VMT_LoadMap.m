function Map = VMT_LoadMap(filetype,coord);

%This routine loads a map file from either a text file or a .mat file. 

%Input:  filetype = 'txt' for a text file (2 col (x,y), no headers); 'mat' for a matlab data file 
%        coord    = 'UTM' for UTM coordinates or 'LL' for latitude, longitude (in dec deg)
%        zone     = zone for UTM coordinates (Removed from Input--will be
%        determined from the data automatically)


%P.R. Jackson, 12-9-08

switch filetype
    case{'txt'}
        defaultpath = 'C:\';
        shorepath = [];
        if exist('VMT\LastDir.mat') == 2
            load('VMT\LastDir.mat');
            if exist(shorepath) == 7
                [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',shorepath);       
            else
                [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',defaultpath);
            end
        else
            [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',defaultpath);
        end
        infile = [shorepath file];
        disp('Loading Map File...' );
        disp(infile);
        data = dlmread(infile);
        switch coord
            case{'LL'}
                % convert lat long into UTMe and UTMn
                [Map.UTMe,Map.UTMn,Map.UTMzone] = deg2utm(data(:,1),data(:,2));
            case{'UTM'}
                Map.UTMe = data(:,1);
                Map.UTMn = data(:,2);
                %Map.UTMzone = zone;
        end
                
    case{'mat'} %assumes Map data structure (above) is present
        [file,path] = uigetfile('*.mat','Select Map (.mat) File');
        infile = [path file];
        disp('Loading Map File...' );
        disp(infile);
        load(infile);
end

Map.infile = infile;

%Save the shorepath
if exist('LastDir.mat') == 2
    save('LastDir.mat','shorepath','-append')
else
    save('LastDir.mat','shorepath')
end