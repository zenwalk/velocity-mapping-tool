function VMT_SaveFigs(path,fignums,figstyle)

%This routine saves the figures (specified by fignums) from VMT as .PNG or
%EPS files (300 dpi).

%P.R. Jackson, USGS, 2-10-09
%Added EPS 8-7-12

%figstyle = 0;  %Set to 1 for print version, otherwise, set to zero for presentation version

disp('{Saving Figures...')
if figstyle
    disp('Figure Style: Print')
else
    disp('Figure Style: Presentation')
end

% Query the user for the format
figformat = questdlg('What figure format would you prefer?', ...
 'Figure Export', ...
 'png','eps','png');


switch figformat
    case 'png'
        for i = fignums
            disp(['Figure ' num2str(i)])
            if i == 1
                VMT_ExportFIG(path,i,'w','k','w',14,300,'png');  %Figure 1 default is white background and figure space, black axes, 14 point fonts
            else
                if figstyle
                    VMT_ExportFIG(path,i,'w','k',[0.3 0.3 0.3],14,300,'png');
                    %VMT_ExportPNG(path,i,[0.2 0.2 0.2],'w',[0.3 0.3 0.3],14,300);  %default is black background and figure space, white axes, 14 point fonts
                else
                    VMT_ExportFIG(path,i,'k','w',[0.3 0.3 0.3],14,300,'png');
                end
            end
        end
     case 'eps'
        for i = fignums
            disp(['Figure ' num2str(i)])
            if i == 1
                VMT_ExportFIG(path,i,'w','k','w',14,300,'eps');  %Figure 1 default is white background and figure space, black axes, 14 point fonts
            else
                if figstyle
                    VMT_ExportFIG(path,i,'w','k',[0.3 0.3 0.3],14,300,'eps');
                    %VMT_ExportPNG(path,i,[0.2 0.2 0.2],'w',[0.3 0.3 0.3],14,300);  %default is black background and figure space, white axes, 14 point fonts
                else
                    VMT_ExportFIG(path,i,'k','w',[0.3 0.3 0.3],14,300,'eps');
                end
            end
        end  
end
disp('Saving Figures Complete')

