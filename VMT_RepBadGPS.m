function A = VMT_RepBadGPS(z,A)

%This routine replaces bad GPS data with bottom track data.

%(adapted from code by J. Czuba)

%Known bugs--Will result in bad values if GPS and Bottom track are both
%bad.  FIXED-9-8-09 with interpolation of missing bottom track from good
%data (may have issues with lots of missing data).

%P.R. Jackson, USGS, 12-9-08 


%% Replace bad GPS with BT

for zi = 1 : z
    % Check for GPS data
    if  sum(nansum(A(zi).Nav.lat_deg)) == 0
        error('No GPS data detected!')
    end 
    
    %Prescreen GPS data (Added 4-8-10)
    indx_blon = find(A(zi).Nav.long_deg < -180 | A(zi).Nav.long_deg > 180);
    indx_blat = find(A(zi).Nav.lat_deg < -90 | A(zi).Nav.long_deg > 90);
    A(zi).Nav.long_deg(indx_blon) = NaN;
    A(zi).Nav.long_deg(indx_blat) = NaN;
    A(zi).Nav.lat_deg(indx_blon)  = NaN;
    A(zi).Nav.lat_deg(indx_blat)  = NaN;
%     disp(zi)
%     length(A(zi).Nav.lat_deg)
%     length(A(zi).Nav.long_deg)
%     figure(1); plot(A(zi).Nav.long_deg)
%     figure(2); plot(A(zi).Nav.lat_deg)

    % convert lat long into xUTM and yUTM
    [A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,A(zi).Comp.utmzone] = ...
        deg2utm(A(zi).Nav.lat_deg,A(zi).Nav.long_deg);
    
    %Check if data spans two UTM zones (Added 1-16-09 P.R. Jackson)
    %(requires mapping toolbox)
    indx = strmatch(A(zi).Comp.utmzone(:,1), A(zi).Comp.utmzone);
%     if sum(indx) < length(A(zi).Comp.utmzone)
%         disp('Caution:  Data Spans Multiple UTM Zones')  %This is not
%         %working yet (1-16-09)
%     end
    
%     [latlim,lonlim] = utmzone(A(zi).Comp.utmzone(1));
%     latindx = find(A(zi).Nav.lat_deg < latlim(1) | A(zi).Nav.lat_deg > latlim(2));
%     lonindx = find(A(zi).Nav.lon_deg < lonlim(1) | A(zi).Nav.lon_deg > lonlim(2));
%     if ~isempty(latindx) | ~isempty(lonindx)
%         beep
%         disp('Caution:  Data Spans Multiple UTM Zones')
%     end    

    % check for repeat values of gps position
    sbt(:,1)=diff(A(zi).Comp.xUTMraw);
    chk(1,1)=1;
    chk(2:A(zi).Sup.noe,1)=sbt(1:end,1);

    % identify bad values
    A(zi).Comp.bv =(isnan(A(zi).Comp.xUTMraw) + (chk==0)) > 0;
    
    %Identify and interpolate missing bottom track data  (Added 9-8-09,
    %P.R. Jackson)  Required to stop bad data return when missing GPS and
    %bottom track.
    bvbt_indx = find(A(zi).Nav.totDistEast == -32768);
    A(zi).Nav.totDistEast(bvbt_indx) = NaN;
    A(zi).Nav.totDistENorth(bvbt_indx) = NaN;
    gvbt_indx = ~isnan(A(zi).Nav.totDistEast);
    A(zi).Nav.totDistEast(bvbt_indx) = interp1(A(zi).Sup.ensNo(gvbt_indx),A(zi).Nav.totDistEast(gvbt_indx),A(zi).Sup.ensNo(bvbt_indx));
    A(zi).Nav.totDistNorth(bvbt_indx) = interp1(A(zi).Sup.ensNo(gvbt_indx),A(zi).Nav.totDistNorth(gvbt_indx),A(zi).Sup.ensNo(bvbt_indx));

    % if bad values exist replace them with bt
    if sum(A(zi).Comp.bv) > 0

        % bracket bad sections
        [I,J] = ind2sub(size(A(zi).Comp.bv),find(A(zi).Comp.bv==1));
        df=diff(I);
        nbrk=sum(df>1)+1;
        [I2,J2] = ind2sub(size(df),find(df>1));

        bg(1)=(I(1)-1);

        for n = 2 : nbrk
            bg(n)=(I(I2(n-1)+1)-1);
        end

        for n = 1 : nbrk -1
            ed(n)=(I(I2(n))+1);
        end

        ed(nbrk)=I(end)+1;

        % determine position based on bt starting from the beginning and
        % end of bad sections then average them together
        A(zi).Comp.xUTMf=NaN(length(A(zi).Comp.xUTMraw),1);
        A(zi).Comp.xUTMb=NaN(length(A(zi).Comp.xUTMraw),1);
        A(zi).Comp.yUTMf=NaN(length(A(zi).Comp.yUTMraw),1);
        A(zi).Comp.yUTMb=NaN(length(A(zi).Comp.yUTMraw),1);
        BG=NaN(length(A(zi).Comp.yUTMraw),1);
        ED=NaN(length(A(zi).Comp.yUTMraw),1);

        xUTM=NaN(length(A(zi).Comp.xUTMraw),3);
        yUTM=NaN(length(A(zi).Comp.yUTMraw),3);

        A(zi).Comp.xUTM=A(zi).Comp.xUTMraw;
        A(zi).Comp.yUTM=A(zi).Comp.yUTMraw;
        A(zi).Comp.xUTM(A(zi).Comp.bv)=NaN;
        A(zi).Comp.yUTM(A(zi).Comp.bv)=NaN;

        for i = 1 : nbrk
            for j = bg(i)+1 : ed(i)-1
                if bg(i) > 0
                    A(zi).Comp.xUTMf(j,1)=A(zi).Comp.xUTMraw(bg(i),1)-A(zi).Nav.totDistEast(bg(i),1)+A(zi).Nav.totDistEast(j,1);
                    A(zi).Comp.yUTMf(j,1)=A(zi).Comp.yUTMraw(bg(i),1)-A(zi).Nav.totDistNorth(bg(i),1)+A(zi).Nav.totDistNorth(j,1);
                    ED(j,1)=((j-bg(i))./(ed(i)-bg(i)));
                    BG(j,1)=((ed(i)-j)./(ed(i)-bg(i)));
                end
                if ed(i) < length(A(zi).Nav.lat_deg)
                    A(zi).Comp.xUTMb(j,1)=A(zi).Comp.xUTMraw(ed(i),1)-A(zi).Nav.totDistEast(ed(i),1)+A(zi).Nav.totDistEast(j,1);
                    A(zi).Comp.yUTMb(j,1)=A(zi).Comp.yUTMraw(ed(i),1)-A(zi).Nav.totDistNorth(ed(i),1)+A(zi).Nav.totDistNorth(j,1);

                end
            end

            if  bg(i) > 0 && ed(i) < length(A(zi).Nav.lat_deg)
                xUTM(:,1)=A(zi).Comp.xUTM;
                xUTM(:,2)=A(zi).Comp.xUTMf.*BG;
                xUTM(:,3)=A(zi).Comp.xUTMb.*ED;
                yUTM(:,1)=A(zi).Comp.yUTM;
                yUTM(:,2)=A(zi).Comp.yUTMf.*BG;
                yUTM(:,3)=A(zi).Comp.yUTMb.*ED;
                xUTM(xUTM==0)=NaN;
                yUTM(yUTM==0)=NaN;
                A(zi).Comp.xUTM=nansum(xUTM,2);
                A(zi).Comp.yUTM=nansum(yUTM,2);

                A(zi).Comp.xUTMf=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.xUTMb=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.yUTMf=NaN(length(A(zi).Comp.yUTMraw),1);
                A(zi).Comp.yUTMb=NaN(length(A(zi).Comp.yUTMraw),1);
                xUTM=NaN(length(A(zi).Comp.xUTMraw),3);
                yUTM=NaN(length(A(zi).Comp.yUTMraw),3);
            else
                xUTM(:,1)=A(zi).Comp.xUTM;
                xUTM(:,2)=A(zi).Comp.xUTMf;
                xUTM(:,3)=A(zi).Comp.xUTMb;
                yUTM(:,1)=A(zi).Comp.yUTM;
                yUTM(:,2)=A(zi).Comp.yUTMf;
                yUTM(:,3)=A(zi).Comp.yUTMb;
                xUTM(xUTM==0)=NaN;
                yUTM(yUTM==0)=NaN;
                A(zi).Comp.xUTM=nanmean(xUTM,2);
                A(zi).Comp.yUTM=nanmean(yUTM,2);

                A(zi).Comp.xUTMf=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.xUTMb=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.yUTMf=NaN(length(A(zi).Comp.yUTMraw),1);
                A(zi).Comp.yUTMb=NaN(length(A(zi).Comp.yUTMraw),1);
                xUTM=NaN(length(A(zi).Comp.xUTMraw),3);
                yUTM=NaN(length(A(zi).Comp.yUTMraw),3);
            end
        end
    else
        A(zi).Comp.xUTM=A(zi).Comp.xUTMraw;
        A(zi).Comp.yUTM=A(zi).Comp.yUTMraw;
    end

    clear I I2 J J2 bg chk df ed i j nbrk sbt xUTM yUTM n zi BG ED
end