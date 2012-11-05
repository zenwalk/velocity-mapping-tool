function [A] = VMT_MBBathyV3(z,A,savefile,beamAng,magVar,wsedata,saveaux)

%This routine computes the multibeam bathymetry from the four beams of the ADCP 
%using a script by D.Mueller (USGS). Beam depths are computed for each
%transect prior to any averaging or mapping.

%V2 adds the ability to export timestamps, pitch, roll, and heading
%(2/1/10)

%Added an identifier for each individual transect to the csv output
%(FEL, 6/14/12)

%V3 Adds capability to handle timeseries of WSE, PRJ 8-7-12

%P.R. Jackson, USGS, 8-7-12 

%% Start 
disp('Computing corrected beam depths')

if length(wsedata.elev) == 1
    disp('WSE is a constant value')
    wsefiletype = 0;
else
    disp('WSE is a timeseries')
    wsefiletype = 1;
end

%% Step through each transect in the given set
figure(1); clf
for zi = 1 : z
    
    % Work on the WSE if a vector
    %WSE vector must have a value for each ensemble, so interpolate given
    %values to ensemble times

    if wsefiletype  %only process as vector if loaded file rather than single value
        %Build an ensemble time vector 
        enstime = datenum([A(zi).Sup.year+2000 A(zi).Sup.month A(zi).Sup.day...
                    A(zi).Sup.hour A(zi).Sup.minute (A(zi).Sup.second+A(zi).Sup.sec100./100)]);
        %Had to add 2000 to year--will not work for years < 2000
        %Check the times (for debugging)
        if 0
            obs_start = datestr(wsedata.obstime(1))
            obs_end = datestr(wsedata.obstime(end))

            ens_start = datestr(enstime(1))
            ens_end = datestr(enstime(end))
        end

        % Interpolate the WSE values to the ENS times
        wse = interp1(wsedata.obstime,wsedata.elev,enstime);
        % Plot for debugging
        if 1
            figure(1); hold on
            plot(enstime,wse,'k-')
            datetick('x',13)
            ylabel('WSE, in meters')
        end
    else
        wse = wsedata.elev; %Single value  
    end
    
    % Compute position and elevation of each beam depth
    [exyz] = depthxyz(A(zi).Nav.depth,A(zi).Sup.draft_cm,...
        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
        A(zi).Sensor.heading_deg,beamAng,...
        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
    
    %Build the auxillary data matrix
    if saveaux
        auxmat = [A(zi).Sup.year+2000 A(zi).Sup.month A(zi).Sup.day...
            A(zi).Sup.hour A(zi).Sup.minute (A(zi).Sup.second+A(zi).Sup.sec100./100) ...
            A(zi).Sensor.heading_deg A(zi).Sensor.pitch_deg A(zi).Sensor.roll_deg ...
            repmat(zi,size(A(zi).Sup.year))]; % Added transect #(zi) FLE 6/14/12    %Had to add 2000 to year--will not work for years < 2000
        auxmat2 = []; 
        for i = 1:length(A(zi).Sup.ensNo); 
            dum = repmat(auxmat(i,:),4,1); 
            auxmat2 = cat(1,auxmat2,dum); 
        end
        clear auxmat dum enstime wse
    end
    
    % Store results    
    idxmbb = find(~isnan(exyz(:,4))& ~isnan(exyz(:,2)));
    if zi==1
        zmbb=[exyz(idxmbb,1) exyz(idxmbb,2)...
            exyz(idxmbb,3) exyz(idxmbb,4)];
        if saveaux
            auxmbb = auxmat2(idxmbb,:);
        end
    else
        zmbb=cat(1,zmbb,[exyz(idxmbb,1)...
            exyz(idxmbb,2) exyz(idxmbb,3) exyz(idxmbb,4)]);
        if saveaux
            auxmbb = cat(1,auxmbb,auxmat2(idxmbb,:));
        end
    end
      
    A(zi).Comp.exyz = exyz(idxmbb,:);
    
        
    clear idxmbb exyz;
    %pack;
end


%% Save the data

if 1
    disp('Exporting multibeam bathymetry')
    disp([savefile(1:end-4) '_mbxyz.csv'])
    outfile = [savefile(1:end-4) '_mbxyz.csv'];
    if saveaux
        outmat = [zmbb auxmbb];
        ofid   = fopen(outfile, 'wt');
        outcount = fprintf(ofid,'EnsNo,     Easting_WGS84_m,    Northing_WGS84_m,  Elev_m,  Year,  Month,  Day,  Hour,  Minute,  Second,  Heading_deg,  Pitch_deg,  Roll_deg,  Transect\n'); % Modified to output transect # FLE 6/14/12
        outcount = fprintf(ofid,'%6.0f, %14.2f, %14.2f, %8.2f, %4.0f, %2.0f, %2.0f, %2.0f, %2.0f, %2.2f, %3.3f, %3.3f, %3.3f, %3.0f\n',outmat');
        fclose(ofid);
    else
        outmat = zmbb;
        ofid   = fopen(outfile, 'wt');
        outcount = fprintf(ofid,'EnsNo,     Easting_WGS84_m,    Northing_WGS84_m,  Elev_m\n');
        outcount = fprintf(ofid,'%6.0f, %14.2f, %14.2f, %8.2f\n',outmat');
        fclose(ofid);
    end
    %dlmwrite([savefile(1:end-4) '_mbxyz.csv'],outmat,'precision',15);   
end