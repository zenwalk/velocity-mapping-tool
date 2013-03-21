function VMT_PlotShoreline(Map)

%Plots a shoreline map given the shoreline data structure 'Map' (see
%VMT_LoadMap.m) on the current map

%P.R. Jackson, 12-9-08

brks = find(Map.UTMe == -9999);

for i = 1:length(brks)+1
    if i == 1
        ll = 1;
        if ~isempty(brks)
            ul = brks(i)-1;
        else
            ul = length(Map.UTMe);
        end
        indx =ll:ul;
    elseif i == length(brks)+1
        ll = brks(i-1)+1;
        ul = length(Map.UTMe);
        indx =ll:ul;
    elseif i > 1 & i < length(brks)+1
        ll = brks(i-1)+1;
        ul = brks(i)-1;
        indx =ll:ul;
    end
    figure(gcf); hold on
    plot(Map.UTMe(indx),Map.UTMn(indx),'w-','LineWidth',2); hold on  
    %patch(Map.UTMe(indx),Map.UTMn(indx),'k','EdgeColor','none'); hold on
    
end
%xlabel('UTM Easting (m)')
%ylabel('UTM Northing (m)')
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])