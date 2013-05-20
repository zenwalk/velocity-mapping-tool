function varargout = VMT(varargin)
% --- THE VELOCITY MAPPING TOOLBOX ---
% 
% VMT is a Matlab-based software for processing and visualizing ADCP data
% collected along transects in rivers or other bodies of water. VMT allows
% rapid processing, visualization, and analysis of a range of ADCP datasets
% and includes utilities to export ADCP data to files compatible with
% ArcGIS, Tecplot, and Google Earth. The software can be used to explore
% patterns of three-dimensional fluid motion through several methods for
% calculation of secondary flows (e.g. Rhoads and Kenworthy, 1998; Lane et
% al., 2000). The software also includes capabilities for analyzing the
% acoustic backscatter and bathymetric data from the ADCP. A user-friendly
% graphical user interface (GUI) enhances program functionality and
% provides ready access to two- and three- dimensional plotting functions,
% allowing rapid display and interrogation of velocity, backscatter, and
% bathymetry data.
% 
% CITATION: 
% Parsons, D. R., Jackson, P. R., Czuba, J. A., Engel, F. L., Rhoads, B.
% L., Oberg, K. A., Best, J. L., Mueller, D. S., Johnson, K. K. and Riley,
% J. D. (2013), Velocity Mapping Toolbox (VMT): a processing and
% visualization suite for moving-vessel ADCP measurements. Earth Surf.
% Process. Landforms. doi: 10.1002/esp.3367
%
%__________________________________________________________________________
% P.R. Jackson, U.S. Geological Survey, Illinois Water Science Center
% (pjackson@usgs.gov)
%
% Code contributed by D. Parsons, D. Mueller, J. Czuba, and F. Engel.
%__________________________________________________________________________

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VMT_OpeningFcn, ...
    'gui_OutputFcn',  @VMT_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%#ok<*DEFNU,*INUSL,*INUSD>

% --- Executes just before VMT is made visible.
function VMT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMT (see VARARGIN)

% Choose default command line output for VMT
handles.output = hObject;

% Build the GUI toolbar:
% ----------------------
handles = buildToolbar(handles);

% Ensure path to utils & docs is available
% ----------------------------------------
if ~isdeployed
    filesep = '\'; % windows
    utilspath = [pwd filesep 'utils'];
    docspath  = [pwd filesep 'doc'];
    toolspath = [pwd filesep 'tools'];
    addpath(utilspath,docspath,toolspath)
end

% Update handles structure
% ------------------------
guidata(hObject, handles);

% Load the GUI preferences:
% -------------------------
load_prefs(handles.figure1)

% Initialize the GUI parameters:
% ------------------------------
guiparams = createGUIparams;
guiparams.vmt_version = 'v4.0';

% Draw the VMT Background
% -----------------
pos = get(handles.figure1,'position');
axes(handles.VMTBackground);
if ~isdeployed %isempty(dir(fullfile(matlabroot,'toolbox','images')))
    X = imread('VMT_Background.png');
    imdisp(X,'size',[pos(4) pos(3)]) % Avoids problems with users not having Image Processing TB
else
    X = imread('VMT_Background.png');
    X = imresize(X, [pos(4) pos(3)]);
    X = uint8(X);
    imshow(X,'Border','tight')
end
uistack(handles.VMTBackground,'bottom')

% Store the application data:
% ---------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Initialize the GUI:
% -------------------
initGUI(handles)
set_enable(handles,'init')
% set(handles.GraphicsExportPanel,'Visible','off')
% set(handles.ProcessingPanel,'Visible','off')
pos = get(handles.figure1,'Position');
% pos(3) = 545;
set(handles.figure1,'Position',pos)
set(handles.figure1,'Resize','on')

% UIWAIT makes VMT wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% [EOF] VMT_OpeningFcn


% --- Outputs from this function are returned to the command line.
function varargout = VMT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% [EOF] VMT_OutputFcn

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)

% Draw the VMT Background
% -----------------
pos = get(handles.figure1,'position');
axes(handles.VMTBackground);
if ~isdeployed %isempty(dir(fullfile(matlabroot,'toolbox','images')))
    X = imread('VMT_Background.png');
    imdisp(X,'size',[pos(4) pos(3)]) % Avoids problems with users not having Image Processing TB
else
    X = imread('VMT_Background.png');
    X = imresize(X, [pos(4) pos(3)]);
    X = uint8(X);
    imshow(X,'Border','tight')
end
uistack(handles.VMTBackground,'bottom')

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
close_button = questdlg(...
    'You are about to exit VMT. Any unsaved work will be lost. Are you sure?',...
    'Exit VMT?','No');
switch close_button
    case 'Yes'
        delete(hObject)
        close all hidden
    otherwise
        return
end
% [EOF] figure1_CloseRequestFcn

%%%%%%%%%%%%%%%%%%%%%%
% MENU BAR CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuOpen_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuOpenASCII_Callback(hObject, eventdata, handles)
loadDataCallback(hObject, eventdata, handles)
% [EOF] menuOpenASCII_Callback

% --------------------------------------------------------------------
function menuOpenMAT_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs = getappdata(handles.figure1,'guiprefs');

% Ask the user to select files:
% -----------------------------
% current_file = fullfile(guiparams.data_folder,guiparams.data_files{1});
% current_file = fullfile(guiprefs.mat_path,guiprefs.mat_file);
if iscell(guiprefs.mat_file)
    uifile = fullfile(guiprefs.mat_path,guiprefs.mat_file{1});
else
    uifile = fullfile(guiprefs.mat_path,guiprefs.mat_file);
end
[filename,pathname] = ...
    uigetfile({'*.mat','MAT-files (*.mat)'}, ...
    'Select MAT File', ...
    uifile, 'MultiSelect','on');

if ischar(filename) % Single MAT file loaded
    % Load the data:
    % --------------
    vars = load(fullfile(pathname,filename));
    
    % Make sure the selected file is a valid file:
    % --------------------------------------------
    varnames = fieldnames(vars);
    if isequal(sort(varnames),{'A' 'Map' 'V' 'z'}')
        guiparams.mat_path = pathname;
        guiparams.mat_file = filename;
        guiparams.z = vars.z;
        guiparams.A = vars.A;
        guiparams.V = vars.V;
        
        % Update the preferences:
        % -----------------------
        guiprefs = getappdata(handles.figure1,'guiprefs');
        guiprefs.mat_path = pathname;
        guiprefs.mat_file = filename;
        setappdata(handles.figure1,'guiprefs',guiprefs)
        store_prefs(handles.figure1,'mat')
                     
        % Re-store the Application Data:
        % ------------------------------
        setappdata(handles.figure1,'guiparams',guiparams)
        
        % Update the GUI:
        % ---------------
        set_enable(handles,'fileloaded')
    else % Not a valid file
        errordlg('The selected file is not a valid ADCP data MAT file.', ...
            'Invalid File...')
    end
    
elseif iscell(filename) % Multiple MAT files loaded
    % Set the filenames
    % -----------------
    guiparams.mat_path = pathname;
    guiparams.mat_file = filename;
    
    % Push status to log window
    % -------------------------
    log_text = {...
        'Loading previously processed MAT files.';...
        'Directory:'};
    log_text = vertcat(log_text, pathname, {'Files:'}, filename');
    statusLogging(handles.LogWindow,log_text)
    
    % Update the Application Data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the persistent preferences:
    % ----------------------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.mat_path = pathname;
    guiprefs.mat_file = filename;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'mat')
        
    % Update the GUI:
    % ---------------
    set_enable(handles,'multiplematfiles')
end

% [EOF] menuOpenMAT_Callback

% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuSaveMAT_Callback(hObject, eventdata, handles)
saveDataCallback(hObject, eventdata, handles)
% [EOF] menuSaveMAT_Callback

% --------------------------------------------------------------------
function menuSaveTecplot_Callback(hObject, eventdata, handles)
SaveTecplotFile_Callback(handles,eventdata,handles)
% [EOF] menuSaveTecplot_Callback

% --------------------------------------------------------------------
function menuSaveKMZFile_Callback(hObject, eventdata, handles)
SaveGoogleEarthFile_Callback(handles,eventdata,handles)
% [EOF] menuSaveKMZFile_Callback

% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuFigureExportsettings_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuPrintFormat_Callback(hObject, eventdata, handles)

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.print        = true;
guiparams.presentation = false;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuPrintFormat,       'Checked','on')
set(handles.menuPresentationFormat,'Checked','off')

% [EOF] menuPrintFormat_Callback


% --------------------------------------------------------------------
function menuPresentationFormat_Callback(hObject, eventdata, handles)

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.print        = false;
guiparams.presentation = true;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuPrintFormat,       'Checked','off')
set(handles.menuPresentationFormat,'Checked','on')

% [EOF] menuPresentationFormat_Callback

% --------------------------------------------------------------------
function menuExportFigures_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');

% Find what plots exist already
fig_handles = findobj('type','figure');
fig_names   = get(fig_handles,'name');

% Remove the VMT GUI as a valid figure in the list
[~, idx] = ismember(get(handles.figure1,'Name'), fig_names);
if ~isempty(idx)
    fig_names(idx) = [];
end

if guiparams.presentation
    figure_style = 'presentation';
else
    figure_style = 'print';
end

[selected_figures] = openFiguresDialog(fig_names,handles.figure1);

if isempty(selected_figures) % User pressed cancel
    return
else
    for i = 1:length(selected_figures)
        VMT_SaveFigs(guiprefs.mat_path,selected_figures(i),figure_style)
    end
end


% [EOF] menuExportFigures_Callback

% --------------------------------------------------------------------
function menuBathymetryExportSettings_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
beam_angle = guiparams.beam_angle; 
magnetic_variation = guiparams.magnetic_variation; 
wse = guiparams.wse;
output_auxilliary_data = guiparams.output_auxiliary_data; 

% Open dialog and allow user to select settings
% ---------------------------------------------
[guiparams.beam_angle,...
    guiparams.magnetic_variation,...
    guiparams.wse,...
    guiparams.output_auxilliary_data] = ...
    exportSettingsDialog(beam_angle,magnetic_variation,wse,output_auxilliary_data,handles.figure1);

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] menuExportSettings_Callback

% --------------------------------------------------------------------
function menuExportMultibeamBathymetry_Callback(hObject, eventdata, handles)
ExportMultibeamBathymetry_Callback(hObject, eventdata, handles);
% [EOF] menuExportMultibeamBathymetry_Callback


% --------------------------------------------------------------------
function menuSaveANVFile_Callback(hObject, eventdata, handles)

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');
PVdata    = guiparams.iric_anv_planview_data;
iric_path = guiprefs.iric_path;
iric_file = guiprefs.iric_file;

% Is there any planview data?
if isempty(PVdata)
    % Nothing to do, warn user
    log_text = {'No planview plot data to export. User must Plot Plan View first.'};
    warndlg(log_text{:},'Nothing to export')
else
    % Save the planview data as output and to an *.anv file with spacing
    % and smoothing (for iRiC)
    log_text = {'Exporting iRic formated ANV vector file...'};
    [iric_file,iric_path] = uiputfile('*.anv','Save *.anv file',...
        fullfile(iric_path,iric_file));
    
    if ischar(iric_path) % The user did not hit "Cancel"
        outfile = fullfile(iric_path,iric_file);
        log_text = vertcat(log_text,{outfile});
        ofid   = fopen(outfile, 'wt');
        outcount = fprintf(ofid,...
            '%8.2f  %8.2f  %5.2f  %3.3f  %3.3f\n',PVdata.outmat);
        fclose(ofid);
    else
        % Return default iric_path and iric_file
        iric_path = guiprefs.iric_path;
        iric_file = guiprefs.iric_file;
    end
end

% Push messages to Log Window:
% ----------------------------
statusLogging(handles.LogWindow, log_text)

% Store the persistent preferences:
% ---------------------------------
guiprefs.iric_file = iric_file;
guiprefs.iric_path = iric_path;
setappdata(handles.figure1,'guiprefs',guiprefs)
store_prefs(handles.figure1,'iric')

% [EOF] menuSaveANVFile_Callback

% --------------------------------------------------------------------
function menuParameters_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuProcessingParameters_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuUnitDischargeCorrection_Callback(hObject, eventdata, handles)
% Turn ON or OFF Unit Discharge Correction

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the GUI & Application Data:
% ----------------------------------
status = get(handles.menuUnitDischargeCorrection,'Checked');
switch status
    case 'on' % Turn it off
        set(handles.menuUnitDischargeCorrection, 'Checked','off')
        guiparams.unit_discharge_correction = false;
    case 'off' % Turn it on
        set(handles.menuUnitDischargeCorrection, 'Checked','on')
        guiparams.unit_discharge_correction = true;
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)


%  [EOF] menuUnitDischargeCorrection_Callback

% --------------------------------------------------------------------
function menuPlottingParameters_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuUnits_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuMetric_Callback(hObject, eventdata, handles)
% Set the Plotting Parameter Units to "metric"

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.english_units = false;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuMetric, 'Checked','on')
set(handles.menuEnglish,'Checked','off')

% [EOF] menuMetric_Callback


% --------------------------------------------------------------------
function menuEnglish_Callback(hObject, eventdata, handles)
% Set the Plotting Parameter Units to "english"

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.english_units = true;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuMetric, 'Checked','off')
set(handles.menuEnglish,'Checked','on')

% [EOF] menuEnglish_Callback


% --------------------------------------------------------------------
function menuSetCrossSectionEndpoints_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuCrossSectionEndpointAutomatic_Callback(hObject, eventdata, handles)
% Set cross-section endpoints automatically

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.set_cross_section_endpoints = false;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuCrossSectionEndpointAutomatic, 'Checked','on')
set(handles.menuCrossSectionEndpointManual,    'Checked','off')

% [EOF] menuCrossSectionEndpointAutomatic_Callback


% --------------------------------------------------------------------
function menuCrossSectionEndpointManual_Callback(hObject, eventdata, handles)
% Set cross-section endpoints manually

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.set_cross_section_endpoints = true;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuCrossSectionEndpointAutomatic, 'Checked','off')
set(handles.menuCrossSectionEndpointManual,    'Checked','on')

% [EOF] menuCrossSectionEndpointManual_Callback




% --------------------------------------------------------------------
function menuPlotStyle_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuStylePrint_Callback(hObject, eventdata, handles)

% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.print        = true;
guiparams.presentation = false;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuStylePrint,        'Checked','on')
set(handles.menuStylePresentation, 'Checked','off')
set(handles.menuPrintFormat,       'Checked','on')
set(handles.menuPresentationFormat,'Checked','off')

% Modify the existing figures
% ---------------------------
% Find what plots exist already
hf = findobj('type','figure');
valid_names = {'Plan View Map'; 'Mean Cross Section Contour'};

% Defaults for Print Stlye Figure
BkgdColor   = 'white';
AxColor     = 'black';
FigColor    = 'white'; % [0.3 0.3 0.3]
FntSize     = 14;

% Loop through valid figures and adjust
% -------------------------------------
if ~isempty(hf) &&  any(ishandle(hf))
    
    for i = 1:length(valid_names)
        switch valid_names{i}
            case 'Plan View Map'
                % Focus the figure
                hff = findobj('name','Plan View Map');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
                    set(gcf,'Color',BkgdColor);
                    set(gca,'FontSize',FntSize)
                    set(get(gca,'Title'),'FontSize',FntSize)
                    set(gca,'Color',FigColor)
                    set(gca,'XColor',AxColor)
                    set(gca,'YColor',AxColor)
                    set(gca,'ZColor',AxColor)
                    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
                    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
                end
            case 'Mean Cross Section Contour'
                % Focus the figure
                hff = findobj('name','Mean Cross Section Contour');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
                    set(gcf,'Color',BkgdColor);
                    set(gca,'FontSize',FntSize)
                    set(get(gca,'Title'),'FontSize',FntSize)
                    set(gca,'Color',FigColor)
                    set(gca,'XColor',AxColor)
                    set(gca,'YColor',AxColor)
                    set(gca,'ZColor',AxColor)
                    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
                    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(findobj(gca,'tag','PlotBedElevation')   ,'color'    ,AxColor)
                    set(findobj(gca,'tag','ReferenceVectorText'),'color'    ,AxColor)
                end
            otherwise
        end
    end
    
    
end


%[EOF] menuStylePrint_Callback


% --------------------------------------------------------------------
function menuStylePresentation_Callback(hObject, eventdata, handles)
% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Update the Application Data:
% ----------------------------
guiparams.print        = false;
guiparams.presentation = true;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
set(handles.menuStylePrint,        'Checked','off')
set(handles.menuStylePresentation, 'Checked','on')
set(handles.menuPrintFormat,       'Checked','off')
set(handles.menuPresentationFormat,'Checked','on')

% Modify the existing figures
% ---------------------------
% Find what plots exist already
hf = findobj('type','figure');
valid_names = {'Plan View Map'; 'Mean Cross Section Contour'};

% Defaults for Print Stlye Figure
% -------------------------------
BkgdColor   = 'black';
AxColor     = 'white';
FigColor    = 'black'; % [0.3 0.3 0.3]
FntSize     = 14;

% Loop through valid figures and adjust
% -------------------------------------
if ~isempty(hf) &&  any(ishandle(hf))
    
    for i = 1:length(valid_names)
        switch valid_names{i}
            case 'Plan View Map'
                % Focus the figure
                hff = findobj('name','Plan View Map');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
                    set(gcf,'Color',BkgdColor);
                    set(gca,'FontSize',FntSize)
                    set(get(gca,'Title'),'FontSize',FntSize)
                    set(gca,'Color',FigColor)
                    set(gca,'XColor',AxColor)
                    set(gca,'YColor',AxColor)
                    set(gca,'ZColor',AxColor)
                    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
                    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
                end
            case 'Mean Cross Section Contour'
                % Focus the figure
                hff = findobj('name','Mean Cross Section Contour');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
                    set(gcf,'Color',BkgdColor);
                    set(gca,'FontSize',FntSize)
                    set(get(gca,'Title'),'FontSize',FntSize)
                    set(gca,'Color',[0.3 0.3 0.3]) %FigColor)
                    set(gca,'XColor',AxColor)
                    set(gca,'YColor',AxColor)
                    set(gca,'ZColor',AxColor)
                    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
                    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(findobj(gca,'tag','PlotBedElevation')   ,'color'    ,AxColor)
                    set(findobj(gca,'tag','ReferenceVectorText'),'color'    ,AxColor)
                end
            otherwise
        end
    end
    
    
end

% [EOF] menuStylePresentation_Callback

% --------------------------------------------------------------------
function menuKMZExport_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Initialize the answer:
% ----------------------
numstr = {num2str(guiparams.vertical_offset)};
answer = NaN;
while isnan(answer)
    answer = inputdlg('Vertical Offset (m)','KMZ Export',1,numstr);
    
    if isempty(answer) % User hits "Cancel"
        return
    end
    
    answer = str2double(answer); % A non-numeric char will be NaN
    % A numeric char will be a double
end

% Re-store the Application data:
% ------------------------------
guiparams.vertical_offset = answer;
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] menuKMZExport_Callback

% --------------------------------------------------------------------
function menuBathymetryParameters_Callback(hObject, eventdata, handles)
% Not implemented

% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuASCII2GIS_Callback(hObject, eventdata, handles)
ASCII2GIS_GUI
% [EOF] menuASCII2GIS_Callback

% --------------------------------------------------------------------
function menuASCII2KML_Callback(hObject, eventdata, handles)

% Get the Application preferences:
% --------------------------------
guiprefs  = getappdata(handles.figure1,'guiprefs');

inpath = guiprefs.kmz_path;
if iscell(guiprefs.kmz_file)
    infile = guiprefs.kmz_file{1};
else
    infile = guiprefs.kmz_file;
end
[log_text,outpath,outfile] = ASCII2KML(inpath,infile);

guiprefs.kmz_path = outpath;
guiprefs.kmz_file = outfile;

% Update persistent preferences
% -----------------------------
setappdata(handles.figure1,'guiprefs',guiprefs)

% [EOF] menuASCII2KML_Callback

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% Empty

% --------------------------------------------------------------------
function menuUsersGuide_Callback(hObject, eventdata, handles)
try
    web('http://code.google.com/p/velocity-mapping-tool/wiki/UserGuide?tm=6')
catch err %#ok<NASGU>
    h = errordlg('No internet connectivity. Try again later.',...
        'Online User Guide unavailable'); %#ok<NASGU>
end
% [EOF] menuASCII2KML_Callback

% --------------------------------------------------------------------
function menuFunctionLibrary_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
% guiparams = getappdata(handles.figure1,'guiparams'); %#ok<NASGU>

try
    % Construct a URL to a local file which can be interpreted by any
    % web-browser
    rootpath = strrep(pwd,filesep,'/');
    webaddress = ['file:///' rootpath '/doc/index.html'];
    system(['start ' webaddress]);
%     [stat,h,url] = web(webaddress) % Produced with m2html (FEX)
catch err 
    error('VMT:guiInterface',...
        horzcat('Unable to open function library. \n',...
        'Attempted to find function library at the URL:\n',...
        '   %s'), webaddress)
    return
end

% [EOF] menuFunctionLibrary_Callback

% --------------------------------------------------------------------
function menuCheckForUpdates_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Check version tag against the web, and display a message
try
    current_vmt_version = urlread('http://hydroacoustics.usgs.gov/movingboat/VMT/VMT_version.txt');
    %     current_vmt_version = urlread('http://hydroacoustics.usgs.gov/movingboat/VMT/VMT_version.txt');
catch err %#ok<NASGU>
    h = msgbox('No internet connection. Try again later.','Check for updates'); %#ok<NASGU>
    return
end

if strcmpi(guiparams.vmt_version,current_vmt_version)
    h = msgbox('VMT is currently up to date, no updates available.','Check for updates'); %#ok<NASGU>
else
    h = msgbox('VMT is out of date. Please visit the VMT homepage.','Check for updates'); %#ok<NASGU>
end
% [EOF] menuCheckForUpdates_Callback

% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
messagestr = ...
    {'The Velocity Mapping Toolbox';...
    ['   Version: ' guiparams.vmt_version];...
    '';...
    '';...
    'With collaborations from:';...
    '   U.S. Geological Survey';...
    '   University of Illinois';...
    '   University of Hull';...
    '';...
    '';...
    'Citation: ';...
    '   Parsons, D. R., Jackson, P. R., Czuba, J. A., Engel, F. L.,';...
    '   Rhoads, B. L., Oberg, K. A., Best, J. L., Mueller, D. S.,';...
    '   Johnson, K. K. and Riley, J. D. (2013), Velocity Mapping';...
    '   Toolbox (VMT): a processing and visualization suite for';...
    '   moving-vessel ADCP measurements. Earth Surf. Process.';...
    '   Landforms.doi: 10.1002/esp.3367'};
h = msgbox(messagestr,'About VMT'); %#ok<NASGU>
% [EOF] menuAbout_Callback




%%%%%%%%%%%%%%%%%%%%%
% TOOLBAR CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function loadDataCallback(hObject, eventdata, handles)
% Read Files into Data Structure using tfile.

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs = getappdata(handles.figure1,'guiprefs');

% Ask the user to select files:
% -----------------------------
current_file = fullfile(guiprefs.ascii_path,guiprefs.ascii_file{1});
[filename,pathname] = uigetfile({'*_ASC.TXT','ASCII (*_ASC.TXT)'}, ...
    'Select the ASCII Output Files', ...
    current_file, ...
    'MultiSelect','on');

if ischar(pathname) % The user did not hit "Cancel"
    guiparams.data_folder = pathname;
    if ischar(filename)
        filename = {filename};
    end
    guiparams.data_files = filename;
    guiparams.mat_file = '';
    
    setappdata(handles.figure1,'guiparams',guiparams)
    
   
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.ascii_path = pathname;
    guiprefs.ascii_file = filename;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'ascii')
    
    % Push messages to Log Window:
    % ----------------------------
    log_text = {...
        '';...
        ['%--- ' datestr(now) ' ---%'];...
        'Current Project Directory:';...
        guiparams.data_folder;
        'Loading the following files into memory:';...
        char(filename)};
    statusLogging(handles.LogWindow, log_text)
    
    % Read the file(s)
    % ----------------
    [~,~,savefile,A,z] = ...
        VMT_ReadFiles(guiparams.data_folder,guiparams.data_files);
    guiparams.savefile = savefile;
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Preprocess the data:
    % --------------------
    A = VMT_PreProcess(z,A);
    
    % Push messages to Log Window:
    % ----------------------------
    log_text = {...
        '   Preprocessing complete.';...
        '   Begin Data Processing...'};
    statusLogging(handles.LogWindow, log_text)
    
    A(1).hgns = guiparams.horizontal_grid_node_spacing;
    A(1).wse  = guiparams.wse;  %Set the WSE to entered value
    [A,V,processing_log_text] = VMT_ProcessTransects(z,A,...
        guiparams.set_cross_section_endpoints,...
        guiparams.unit_discharge_correction);
    
    % Push messages to Log Window:
    % ----------------------------
    statusLogging(handles.LogWindow, processing_log_text)
    
    % Store the data:
    % ---------------
    guiparams.z = z;
    guiparams.A = A;
    guiparams.V = V;
    setappdata(handles.figure1,'guiparams',guiparams)
    
      
    % Update the GUI:
    % ---------------
    set_enable(handles,'fileloaded')
end
% [EOF] loadDataCallback



% --------------------------------------------------------------------
function saveDataCallback(hObject, eventdata, handles)
% SaveMATFile_Callback(handles.SaveMATFile,eventdata,handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z   = guiparams.z;   %#ok<NASGU>
A   = guiparams.A;   %#ok<NASGU>
V   = guiparams.V;   %#ok<NASGU>
Map = guiparams.Map; %#ok<NASGU>

[the_file,the_path] = ...
    uiputfile({'*.mat','MAT-Files (*.mat)'}, ...
    'Save MAT-File', ...
    fullfile(guiparams.mat_path,guiparams.savefile));

% Save the processed data to a MAT file:
% --------------------------------------
if ischar(the_file)
    guiparams.mat_path = the_path;
    guiparams.mat_file = the_file;
    guiparams.savefile = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.mat_path = the_path;
    guiprefs.mat_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'mat')
    
    [pathstr,filename,extension] = fileparts([guiparams.mat_path guiparams.savefile]);
    savefile = fullfile(pathstr,[filename extension]);
    %h = msgbox(['Saving processed data in MAT File ''' filename extension ''''], ...
    %    'Saving Processed Data File...'); %#ok<NASGU>
    log_text = {...
        'Saving Processed Data File...';...
        savefile};
    statusLogging(handles.LogWindow,log_text)
    save(savefile,'A','V','z','Map')
end

% [EOF] saveDataCallback


% --------------------------------------------------------------------
function saveBathymetryCallback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z   = guiparams.z;
A   = guiparams.A;
% V   = guiparams.V;   %#ok<NASGU>
% Map = guiparams.Map; %#ok<NASGU>

% Compute multibeam bathymetry:
% -----------------------------
msgbox('Processing Bathymetry...Please Be Patient','VMT Status','help','replace')
%A = VMT_MBBathy(z,A,savefile,handles.beam_angle,handles.MagneticVariation,handles.WSE);
VMT_MBBathy(z,A,savefile, ...
    guiparams.beam_angle, ...
    guiparams.magnetic_variation, ...
    guiparams.wse, ...
    guiparams.output_auxiliary_data);

msgbox('Bathymetry Output Complete','VMT Status','help','replace')

% [EOF] saveBathymetryCallback

% --------------------------------------------------------------------
function plottingParametersCallback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

[guiparams.english_units,guiparams.set_cross_section_endpoints,...
    guiparams.presentation,guiparams.print] = ...
    plotParametersDialog(guiparams.english_units, ...
    guiparams.set_cross_section_endpoints,...
    guiparams.presentation,guiparams.print,...
    handles.figure1);

% Update the GUI:
% ---------------
if guiparams.english_units
    set(handles.menuMetric, 'Checked','off')
    set(handles.menuEnglish,'Checked','on')
else
    set(handles.menuMetric, 'Checked','on')
    set(handles.menuEnglish,'Checked','off')
end

if guiparams.set_cross_section_endpoints
    set(handles.menuCrossSectionEndpointAutomatic,'Checked','off')
    set(handles.menuCrossSectionEndpointManual,   'Checked','on')
else
    set(handles.menuCrossSectionEndpointAutomatic,'Checked','on')
    set(handles.menuCrossSectionEndpointManual,   'Checked','off')
end

if guiparams.presentation
    menuStylePresentation_Callback(hObject, eventdata, handles)
%     set(handles.menuStylePrint,           'Checked','off')
%     set(handles.menuStylePresentation,    'Checked','on')
%     set(handles.menuPrintFormat,          'Checked','off')
%     set(handles.menuPresentationFormat,   'Checked','on')
else
    menuStylePrint_Callback(hObject, eventdata, handles)
%     set(handles.menuStylePrint,           'Checked','on')
%     set(handles.menuStylePresentation,    'Checked','off')
%     set(handles.menuPrintFormat,          'Checked','on')
%     set(handles.menuPresentationFormat,   'Checked','off')
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] plottingParametersCallback


% --------------------------------------------------------------------
function processingParametersCallback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z   = guiparams.z;   %#ok<NASGU>
A   = guiparams.A;   %#ok<NASGU>
V   = guiparams.V;   %#ok<NASGU>
Map = guiparams.Map; %#ok<NASGU>

% [EOF] processingParametersCallback


% --------------------------------------------------------------------
function shiptracksPlotCallback(hObject, eventdata, handles)
% Plot 1

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z = guiparams.z;
A = guiparams.A;
V = guiparams.V; %#ok<NASGU>
% Map = guiparams.Map;
setends = guiparams.set_cross_section_endpoints;

% Process the transects:
% ----------------------
A(1).hgns = guiparams.horizontal_grid_node_spacing;
A(1).wse  = guiparams.wse;  %Set the WSE to entered value
[A,V,processing_log_text] = VMT_ProcessTransects(z,A,...
    guiparams.set_cross_section_endpoints,guiparams.unit_discharge_correction);

% Push messages to Log Window:
% ----------------------------
log_text = {'Plotting Shiptracks (reprocessing)'};
statusLogging(handles.LogWindow, vertcat(log_text,processing_log_text))

% Create or replot the Shiptracks
% -------------------------------
% Grab the axes to the plot
% axes(handles.Plot1Shiptracks);
VMT_PlotShiptracks(A,V,z,setends,handles.Plot1Shiptracks); % PLOT 1

%%%%%%%%%%%%%%%%%%%%%%%%%
% New plot display window
% h = VMT_CreatePlotDisplay('shiptracks');
% h = figure(1); clf
%%%%%%%%%%%%%%%%%%%%%%%%%

% [EOF] shiptracksPlotCallback


% --------------------------------------------------------------------
function planviewPlotCallback(hObject, eventdata, handles)
% Plot 2

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

if iscell(guiparams.mat_file) % Multiple MAT files loaded
    % Push messages to Log Window:
    % ----------------------------
    log_text = {'Plotting Multiple Transects (Planview)'};
    statusLogging(handles.LogWindow, log_text)
    
       
    % Push plotting parameters to log window:
    % ---------------------------------------
    log_text = {...
        'Plan View Plotting Parameters';...
        sprintf('   Depth range %3.1f to %3.1f m',guiparams.depth_range_min, guiparams.depth_range_max);...
        sprintf('   Vector scale: %d',guiparams.vector_scale_plan_view);...
        sprintf('   Vector spacing: %d',guiparams.vector_spacing_plan_view);...
        sprintf('   Smoothing window size: %d',guiparams.smoothing_window_size);...
        };
    statusLogging(handles.LogWindow, log_text)
    
    % Plot the data:
    % --------------
    z = [];
    A = [];
    V = [];
    Map = [];
    depth_range = [guiparams.depth_range_min guiparams.depth_range_max];
    [PVdata,~,log_text] = VMT_PlotPlanViewQuivers(z,A,V,Map, ...
        depth_range, ...
        guiparams.vector_scale_plan_view, ...
        guiparams.vector_spacing_plan_view, ...
        guiparams.smoothing_window_size, ...
        guiparams.display_shoreline, ...
        guiparams.english_units, ...
        guiparams.mat_file, ...
        guiparams.mat_path); % PLOT2
    statusLogging(handles.LogWindow, log_text)
    
    % Plot a Shoreline Map:
    % ---------------------
    if guiparams.display_shoreline
        Map = VMT_LoadMap('txt','UTM');
        %figure(2); clf
        VMT_PlotShoreline(Map)
        log_text = {...
            '   Loading map file.';...
            '   Plotting shoreline.'...
            };
        statusLogging(handles.LogWindow, log_text)
    else
        Map = [];
    end
    
else
    z = guiparams.z;
    A = guiparams.A;
    % V = guiparams.V;
    Map = guiparams.Map;
    
    % Push messages to Log Window:
    % ----------------------------
    log_text = {'Plotting Depth Averaged Vectors (reprocessing)'};
    statusLogging(handles.LogWindow, log_text)
    
        
    % Preprocess the data:
    % --------------------
    A = VMT_PreProcess(z,A);
    
    % Process the transects:
    % ----------------------
    A(1).hgns = guiparams.horizontal_grid_node_spacing;
    A(1).wse  = guiparams.wse;  %Set the WSE to entered value
    [A,V,processing_log_text] = VMT_ProcessTransects(z,A,...
        guiparams.set_cross_section_endpoints,guiparams.unit_discharge_correction);
    
    % Push messages to Log Window:
    % ----------------------------
    statusLogging(handles.LogWindow, processing_log_text)
    
    % Plot the cross section:
    % -----------------------
    log_text = {...
        'Plan View Plotting Parameters';...
        sprintf('   Depth range %3.1f to %3.1f m',guiparams.depth_range_min, guiparams.depth_range_max);...
        sprintf('   Vector scale: %d',guiparams.vector_scale_plan_view);...
        sprintf('   Vector spacing: %d',guiparams.vector_spacing_plan_view);...
        sprintf('   Smoothing window size: %d',guiparams.smoothing_window_size);...
        };
    statusLogging(handles.LogWindow, log_text)
    
    % Plot the data:
    % --------------
    %msgbox('Plotting Plan View','VMT Status','help','replace');
    depth_range = [guiparams.depth_range_min guiparams.depth_range_max];
    % if ~guiparams.map_depth_averaged_velocities
    
    [PVdata,~,log_text] = VMT_PlotPlanViewQuivers(z,A,V,Map, ...
        depth_range, ...
        guiparams.vector_scale_plan_view, ...
        guiparams.vector_spacing_plan_view, ...
        guiparams.smoothing_window_size, ...
        guiparams.display_shoreline, ...
        guiparams.english_units); % PLOT2
    statusLogging(handles.LogWindow, log_text)
    
    % Plot a Shoreline Map:
    % ---------------------
    if guiparams.display_shoreline
        Map = VMT_LoadMap('txt','UTM');
        %figure(2); clf
        VMT_PlotShoreline(Map)
        log_text = {...
            '   Loading map file.';...
            '   Plotting shoreline.'...
            };
        statusLogging(handles.LogWindow, log_text)
    else
        Map = [];
    end
    
end

if guiparams.add_background
    log_text = VMT_OverlayDOQQ(guiparams.data_folder);
    statusLogging(handles.LogWindow, log_text)
end

% Save the PVdata to persistent guiparams
% ---------------------------------------
guiparams.iric_anv_planview_data = PVdata;
setappdata(handles.figure1,'guiparams',guiparams);

% Force plot to be formated properly
% ----------------------------------
if guiparams.presentation
    menuStylePresentation_Callback(hObject, eventdata, handles)
else
    menuStylePrint_Callback(hObject, eventdata, handles)
end

% [EOF] planviewPlotCallback


% --------------------------------------------------------------------
function crosssectionPlotCallback(hObject, eventdata, handles)
% Plot 3

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z = guiparams.z;
A = guiparams.A;
% V = guiparams.V;
% Map = guiparams.Map;

% Preprocess the data:
% --------------------
A = VMT_PreProcess(z,A);

% Push messages to Log Window:
% ----------------------------
log_text = {'Plotting Cross Section (reprocessing)'};
statusLogging(handles.LogWindow, log_text)

% Process the transects:
% ----------------------
A(1).hgns = guiparams.horizontal_grid_node_spacing;
A(1).wse  = guiparams.wse;  %Set the WSE to entered value
[A,V,processing_log_text] = VMT_ProcessTransects(z,A,...
    guiparams.set_cross_section_endpoints,guiparams.unit_discharge_correction);

% Push messages to Log Window:
% ----------------------------
statusLogging(handles.LogWindow, processing_log_text)

% Plot the cross section:
% -----------------------
log_text = {...
    'Cross Section Plotting Parameters';...
    sprintf('   Contour variable: %s'          ,guiparams.contours(guiparams.idx_contour).string);...
    sprintf('   Vertical exaggeration: %d'     ,guiparams.vertical_exaggeration);...
    sprintf('   Vector scale: %3.1f'           ,guiparams.vector_scale_cross_section);...
    sprintf('   Horizontal vector spacing: %d' ,guiparams.horizontal_vector_spacing);...
    sprintf('   Vertical vector spacing: %d'   ,guiparams.vertical_vector_spacing);...
    sprintf('   Horizontal smooting window: %d',guiparams.horizontal_smoothing_window);...
    sprintf('   Vertical smoothing window: %d' ,guiparams.vertical_smoothing_window);...
    };
if guiparams.plot_secondary_flow_vectors
    log_text = vertcat(log_text, {...
        sprintf('   Vector variable: %s',guiparams.secondary_flows(guiparams.idx_secondary_flow_vector_variable).string);...
        sprintf('   Inc. vertical component?: %d',guiparams.include_vertical_velocity)...
        });
end
% Push messages to Log Window:
% ----------------------------
statusLogging(handles.LogWindow, log_text)

if guiparams.plot_secondary_flow_vectors
    %msgbox('Plotting Cross Section','VMT Status','help','replace')
    V = VMT_SmoothVar(V, ...
        ...guiparams.contour, ...
        guiparams.horizontal_smoothing_window, ...
        guiparams.vertical_smoothing_window);
    V = VMT_SmoothVar(V, ...
        ...guiparams.secondary_flow_vector_variable, ...
        guiparams.horizontal_smoothing_window, ...
        guiparams.vertical_smoothing_window);
    [~,A,V,plot_cont_log_text] = VMT_PlotXSContQuiver(z,A,V, ...
        guiparams.contour, ...
        guiparams.vector_scale_cross_section, ...
        guiparams.vertical_exaggeration, ...
        guiparams.horizontal_vector_spacing, ...
        guiparams.vertical_vector_spacing, ...
        guiparams.secondary_flow_vector_variable, ...
        guiparams.include_vertical_velocity, ...
        guiparams.english_units); %#ok<ASGLU> % PLOT3
    
elseif ~guiparams.plot_secondary_flow_vectors
    V = VMT_SmoothVar(V, ...
        ...guiparams.contour, ...
        guiparams.horizontal_smoothing_window, ...
        guiparams.vertical_smoothing_window);
    
    [~,A,V,zmin,zmax,plot_cont_log_text] = VMT_PlotXSCont(z,A,V, ...
        guiparams.contour, ...
        guiparams.vertical_exaggeration, ...
        guiparams.english_units);  %#ok<ASGLU>
    
    guiparams.zmin = zmin;
    guiparams.zmax = zmax;
    setappdata(handles.figure1,'guiparams',guiparams)
end

% Force plot to be formated properly
% ----------------------------------
if guiparams.presentation
    menuStylePresentation_Callback(hObject, eventdata, handles)
else
    menuStylePrint_Callback(hObject, eventdata, handles)
end

% Push messages to Log Window:
% ----------------------------
statusLogging(handles.LogWindow, plot_cont_log_text)
% msgbox('Plotting Complete','VMT Status','help','replace')

% [EOF] crosssectionPlotCallback


%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA EXPORT CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function SaveMATFile_Callback(hObject, eventdata, handles)
% saveDataCallback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
z   = guiparams.z;   %#ok<NASGU>
A   = guiparams.A;   %#ok<NASGU>
V   = guiparams.V;   %#ok<NASGU>
Map = guiparams.Map; %#ok<NASGU>

[the_file,the_path] = ...
    uiputfile({'*.mat','MAT-Files (*.mat)'}, ...
    'Save MAT-File', ...
    fullfile(guiparams.mat_path,guiparams.savefile));

% Save the processed data to a MAT file:
% --------------------------------------
if ischar(the_file)
    guiparams.mat_path = the_path;
    guiparams.mat_file = the_file;
    guiparams.savefile = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.mat_path = the_path;
    guiprefs.mat_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'mat')
    
    [~,filename,extension] = fileparts(guiparams.savefile);
    savefile = [filename extension];
    h = msgbox(['Saving processed data in MAT File ''' savefile ''''], ...
        'Saving Processed Data File...'); %#ok<NASGU>
    disp('Saving Processed Data File...')
    disp(savefile)
    save(savefile,'A','V','z','Map')
end

% [EOF] SaveMATFile_Callback


% --------------------------------------------------------------------
function SaveTecplotFile_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
% z   = guiparams.z;
% A   = guiparams.A;
V   = guiparams.V;
% Map = guiparams.Map;

[the_file,the_path] = ...
    uiputfile({'*.dat','Tecplot Files (*.dat)'}, ...
    'Save Tecplot File', ...
    fullfile(guiparams.tecplot_path,guiparams.tecplot_file));

% Output the data (no smoothing) to Tecplot:
% ------------------------------------------
if ischar(the_file)
    guiparams.tecplot_path = the_path;
    guiparams.tecplot_file = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.tecplot_path = the_path;
    guiprefs.tecplot_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'tecplot')
    
    % Push to log window
    % ------------------
    log_text = {...
        'Exporting Data to Tecplot (*.dat) File...';...
        'Directory:';...
        the_path;...
        ['Filename: ' the_file]};
    statusLogging(handles.LogWindow,log_text)
        
    if isempty(V)
        A = guiparams.A;
        A(1).hgns = guiparams.horizontal_grid_node_spacing;
        A(1).wse  = guiparams.wse;  %Set the WSE to entered value
        [~,V,processing_log_text] = VMT_ProcessTransects(z,A,...
            guiparams.set_cross_section_endpoints,...
            guiparams.unit_discharge_correction);
    end
    VMT_BuildTecplotFile(V,fullfile(guiparams.tecplot_path,guiparams.tecplot_file));
    
    % Push to log window
    % ------------------
    log_text = {'Exporting XS Bathy Data to Tecplot (*.dat) File...'};
    statusLogging(handles.LogWindow,log_text)
    
    VMT_BuildTecplotFile_XSBathy(V,fullfile(guiparams.tecplot_path,guiparams.tecplot_file));
    
    % Push to log window
    % ------------------
    log_text = {'Tecplot Export Complete'};
    statusLogging(handles.LogWindow,log_text)
   
end

% [EOF] SaveTechplotFile_Callback


% --------------------------------------------------------------------
function SaveGoogleEarthFile_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
% z   = guiparams.z;
A   = guiparams.A;
V   = guiparams.V;
Map = guiparams.Map; %#ok<NASGU>

[the_file,the_path] = ...
    uiputfile({'*.kmz','Google Earth Files (*.kmz)'}, ...
    'Save Google Earth File', ...
    fullfile(guiparams.kmz_path,guiparams.kmz_file));

% Save the processed data to a Google Earth (KMZ) file:
% -----------------------------------------------------
if ischar(the_file)
    guiparams.kmz_path = the_path;
    guiparams.kmz_file = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.kmz_path = the_path;
    guiprefs.kmz_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'kmz')
    
    %     if guiparams.display_shoreline
    %         VMT_Shoreline2GE_3D(A,Map, ...
    %                             guiparams.vertical_exaggeration, ...
    %                             guiparams.vertical_offset);
    %     end
    if isempty(V)
        A = guiparams.A;
        A(1).hgns = guiparams.horizontal_grid_node_spacing;
        A(1).wse  = guiparams.wse;  %Set the WSE to entered value
        [~,V,processing_log_text] = VMT_ProcessTransects(z,A,...
            guiparams.set_cross_section_endpoints,...
            guiparams.unit_discharge_correction);
    end
    VMT_MeanXS2GE_3D(A,V,[], ...
        fullfile(guiparams.kmz_path,guiparams.kmz_file), ...
        guiparams.vertical_exaggeration, ...
        guiparams.vertical_offset);
end

% [EOF] SaveGoogleEarthFile_Callback


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA EXPORT/BATHYMETRY CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function ExportMultibeamBathymetry_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');

[the_file,the_path] = ...
    uiputfile({'*.csv','Multibeam Bathymetry Files (*.csv)'}, ...
    'Export Multibeam Bathymetry', ...
    fullfile(guiprefs.multibeambathymetry_path, ...
    guiprefs.multibeambathymetry_file));

if ischar(the_file)
    guiparams.multibeambathymetry_path = the_path;
    guiparams.multibeambathymetry_file = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.multibeambathymetry_path = the_path;
    guiprefs.multibeambathymetry_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'multibeambathymetry')
    
    if guiparams.output_auxiliary_data
    end
    
    %msgbox('Processing Bathymetry...Please Be Patient','VMT Status','help','replace')
    
    savefile = fullfile(guiparams.multibeambathymetry_path, ...
        guiparams.multibeambathymetry_file);
    
    log_text = {'Multibeam bathymetry file saved to:';...
        ['   ' savefile]};
    statusLogging(handles.LogWindow,log_text)
    
    VMT_MBBathy(guiparams.z, ...
        guiparams.A, ...
        savefile, ...
        guiparams.beam_angle, ...
        guiparams.magnetic_variation, ...
        guiparams.wse, ...
        guiparams.output_auxiliary_data);
    
    %msgbox('Bathymetry Output Complete','VMT Status','help','replace')
    
end

% [EOF] ExportMultibeamBathymetry_Callback


% --------------------------------------------------------------------
function BeamAngle_Callback(hObject, eventdata, handles)
% Get the beam angle

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_beam_angle = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_beam_angle);
is_positive = new_beam_angle>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.beam_angle = new_beam_angle;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.beam_angle)
end

% [EOF] BeamAngle_Callback


% --------------------------------------------------------------------
function MagneticVariation_Callback(hObject, eventdata, handles)
% Get the Magnetic Variation

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_magnetic_variation = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_magnetic_variation);
is_positive = new_magnetic_variation>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.magnetic_variation = new_magnetic_variation;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.magnetic_variation)
end

% [EOF] MagneticVariation_Callback


% --------------------------------------------------------------------
function WSE_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_wse = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_wse);
is_positive = new_wse>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.wse = new_wse;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.wse)
end

% [EOF] WSE_Callback


% --------------------------------------------------------------------
function OutputAuxiliaryData_Callback(hObject, eventdata, handles)
% Bathymetry Auxillary Data

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.output_auxiliary_data = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] OutputAuxiliaryData_Callback


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/PLAN VIEW PLOT CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function DepthRangeMin_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_depth_range_min = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_depth_range_min);
is_positive = new_depth_range_min>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.depth_range_min = new_depth_range_min;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.depth_range_min)
end

% [EOF] DepthRangeMin_Callback


% --------------------------------------------------------------------
function DepthRangeMax_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_depth_range_max = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_depth_range_max);
is_positive = new_depth_range_max>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.depth_range_max = new_depth_range_max;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.depth_range_max)
end

% [EOF] DepthMax_Callback


% --------------------------------------------------------------------
function VectorScalePlanView_Callback(hObject, eventdata, handles)
% Set quiver scale (contour)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_vector_scale_plan_view = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_vector_scale_plan_view);
is_positive = new_vector_scale_plan_view>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.vector_scale_plan_view = round(new_vector_scale_plan_view);
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.vector_scale_plan_view)
end

% [EOF] VectorScalePlanView_Callback


% --------------------------------------------------------------------
function VectorSpacingPlanview_Callback(hObject, eventdata, handles)
% Set quiver spacing (contour, horizontal)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_vector_spacing_plan_view = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_vector_spacing_plan_view);
is_positive = new_vector_spacing_plan_view>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.vector_spacing_plan_view = round(new_vector_spacing_plan_view);
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.vector_spacing_plan_view)
end

% [EOF] VectorSpacingPlanview_Callback


% --------------------------------------------------------------------
function SmoothingWindowSize_Callback(hObject, eventdata, handles)
% Plan View smoothing window size

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_smoothing_window_size = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_smoothing_window_size);
is_positive = new_smoothing_window_size>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.smoothing_window_size = round(new_smoothing_window_size);
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.smoothing_window_size)
end

% [EOF] SmoothingWindowSize_Callback


% --------------------------------------------------------------------
function MapDepthAveragedVelocities_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.map_depth_averaged_velocities = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] MapDepthAveragedVelocities_Callback


% --------------------------------------------------------------------
function DisplayShoreline_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.display_shoreline = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] DisplayShoreline_Callback


% --------------------------------------------------------------------
function AddBackground_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.add_background = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] AddBackground_Callback


% --------------------------------------------------------------------
function PlotPlanView_Callback(hObject, eventdata, handles)
planviewPlotCallback(hObject, eventdata, handles)
% [EOF] PlotPlanView_Callback


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/SHIP TRACKS PLOT CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function HorizontalGridNodeSpacing_Callback(hObject, eventdata, handles)
% Set the horizontal grid node spacing

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_horizontal_grid_node_spacing = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_horizontal_grid_node_spacing);
is_positive = new_horizontal_grid_node_spacing>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.horizontal_grid_node_spacing = round(new_horizontal_grid_node_spacing);
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.horizontal_grid_node_spacing)
end

% [EOF] HorizontalGridNodeSpacing_Callback


% --------------------------------------------------------------------
function SetCrossSectionEndpoints_Callback(hObject, eventdata, handles)
% Set the cross section endpoints manually

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.set_cross_section_endpoints = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] SetCrossSectionEndpoints_Callback


% --------------------------------------------------------------------
function PlotShiptracks_Callback(hObject, eventdata, handles)
shiptracksPlotCallback(hObject, eventdata, handles)
% [EOF] PlotShiptracks_Callback


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/CROSS SECTION PLOT CALLBACKS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function Contour_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
idx_variable = get(hObject,'Value');
guiparams.idx_contour = idx_variable;
guiparams.contour = guiparams.contours(idx_variable).variable;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] Contour_Callback


% --------------------------------------------------------------------
function VerticalExaggeration_Callback(hObject, eventdata, handles)
% Set vertical exaggeration

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.vertical_exaggeration = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] VerticalExaggeration_Callback


% --------------------------------------------------------------------
function VectorScaleCrossSection_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.vector_scale_cross_section = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] VectorScaleCrossSection_Callback


% --------------------------------------------------------------------
function HorizontalVectorSpacing_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.horizontal_vector_spacing = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] HorizontalVectorSpacing_Callback


% --------------------------------------------------------------------
function VerticalVectorSpacing_Callback(hObject, eventdata, handles)
% Get the vertical quiver spacing for contour plots

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.vertical_vector_spacing = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] VerticalVectorSpacing_Callback


% --------------------------------------------------------------------
function HorizontalSmoothingWindow_Callback(hObject, eventdata, handles)
% Horizontal Smoothing

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.horizontal_smoothing_window = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] HorizontalSmoothingWindow_Callback


% --------------------------------------------------------------------
function VerticalSmoothingWindow_Callback(hObject, eventdata, handles)
% Vertical Smoothing

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.vertical_smoothing_window = str2double(get(hObject,'String'));

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Update the GUI:
% ---------------
% updateGUI(handles,guiparams)

% [EOF] VerticalSmoothingWindow_Callback


% --------------------------------------------------------------------
function PlotSecondaryFlowVectors_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.plot_secondary_flow_vectors = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] PlotSecondaryFlowVectors_Callback


% --------------------------------------------------------------------
function SecondaryFlowVectorVariable_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
idx_variable = get(hObject,'Value');
guiparams.idx_secondary_flow_vector_variable = idx_variable;
guiparams.secondary_flow_vector_variable = guiparams.secondary_flows(idx_variable).variable;

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] SecondaryFlowVectorVariable_Callback


% --------------------------------------------------------------------
function IncludeVerticalVelocity_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.include_vertical_velocity = logical(get(hObject,'Value')); % boolean

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] IncludeVerticalVelocity_Callback


% --------------------------------------------------------------------
function PlotCrossSection_Callback(hObject, eventdata, handles)
crosssectionPlotCallback(hObject, eventdata, handles)
% [EOF] PlotCrossSection_Callback


% --------------------------------------------------------------------
function ClearLog_Callback(hObject, eventdata, handles)
set(handles.LogWindow,'string','')
% [EOF] ClearLog_Callback

% --------------------------------------------------------------------
function SaveLog_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');
% z   = guiparams.z;   %#ok<NASGU>
% A   = guiparams.A;   %#ok<NASGU>
% V   = guiparams.V;   %#ok<NASGU>
% Map = guiparams.Map; %#ok<NASGU>

[the_file,the_path] = ...
    uiputfile({'*.txt','TXT-Files (*.txt)'}, ...
    'Choose where to save the log file', ...
    fullfile(guiprefs.log_path,guiprefs.log_file));

% Save the log to a TXT file:
% ---------------------------
if ischar(the_file)
    guiparams.log_path = the_path;
    guiparams.log_file = the_file;
    %guiparams.savefile = the_file;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the preferences:
    % -----------------------
    guiprefs = getappdata(handles.figure1,'guiprefs');
    guiprefs.log_path = the_path;
    guiprefs.log_file = the_file;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'log')
    
    [~,filename,extension] = fileparts(the_file);
    savefile = [the_path filename extension];
    h = msgbox(['Saving log to: ''' savefile ''''], ...
        'Saving Log File...'); %#ok<NASGU>
    
    logfile = get(handles.LogWindow,'string');
    [nrows,~]= size(logfile);
    fid = fopen(savefile, 'w');
    for row=1:nrows
        fprintf(fid, '%s \n', logfile{row,:});
    end
    fclose(fid);
end
% [EOF] SaveLog_Callback

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function handles = buildToolbar(handles)

icons = getIcons;
ht = uitoolbar('Parent',handles.figure1);

% Load data
% icon = imread('C:\Users\pfricker\Desktop\icons\file_open.png');
% icon = double(icon)/(2^16-1);
% icon(icon==0) = NaN;
handles.toolbarLoadData = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(1).data, ...
    'TooltipString','Open ASCII File');

% Save data
% icon = imread('C:\Users\pfricker\Desktop\icons\file_save.png');
% icon = double(icon)/(2^16-1);
% icon(icon==0) = NaN;
handles.toolbarSaveMatFile = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(2).data, ...
    'TooltipString','Save MAT File', ...
    'Separator',    'on');


% Save bathymetry
%icon = ones(16,16,3);
handles.toolbarSaveBathymetry = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(5).data, ...
    'TooltipString','Export Bathymetry');

% Save figures
% icon = ones(16,16,3);
handles.toolbarSaveFigures = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(6).data, ...
    'TooltipString','Export Figures');


% Plotting parameters
% [icon,map] = imread('C:\Users\pfricker\Desktop\icons\PlotGeneralElement.gif');
% icon = ind2rgb(icon,map);
handles.toolbarPlottingParameters = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(3).data, ...
    'TooltipString','Plotting Parameters', ...
    'Separator',    'on');

% Processing parameters
% [icon,map] = imread('C:\Users\pfricker\Desktop\icons\ParameterIcon.gif');
% icon = ind2rgb(icon,map);
handles.toolbarProcessingParameters = ...
    uipushtool('Parent',       ht, ...
    'CData',        icons(4).data, ...
    'TooltipString','Processing Parameters');

% % Plot 1: Shiptracks
% handles.shiptracksPlot = ...
%     uipushtool('Parent',       ht, ...
%                'CData',        icon, ...
%                'TooltipString','Shiptracks plot', ...
%                'Separator',    'on');
%
% % Plot 2: Plan view
% handles.planviewPlot = ...
%     uipushtool('Parent',       ht, ...
%                'CData',        icon, ...
%                'TooltipString','Plan view plot');
%
% % Plot 3: Cross section
% handles.crosssectionPlot = ...
%     uipushtool('Parent',       ht, ...
%                'CData',        icon, ...
%                'TooltipString','Cross section plot');

set(handles.toolbarLoadData,            'ClickedCallback',{@loadDataCallback,handles})
set(handles.toolbarSaveMatFile,         'ClickedCallback',{@saveDataCallback,handles})
set(handles.toolbarSaveBathymetry,      'ClickedCallback',{@ExportMultibeamBathymetry_Callback,handles})
set(handles.toolbarSaveFigures,         'ClickedCallback',{@menuExportFigures_Callback,handles})
set(handles.toolbarPlottingParameters,  'ClickedCallback',{@plottingParametersCallback,handles})
set(handles.toolbarProcessingParameters,'ClickedCallback',{@processingParametersCallback,handles})
% set(handles.shiptracksPlot,      'ClickedCallback',{@shiptracksPlotCallback,handles})
% set(handles.planviewPlot,        'ClickedCallback',{@planviewPlotCallback,handles})
% set(handles.crosssectionPlot,    'ClickedCallback',{@crosssectionPlotCallback,handles})

% [EOF] buildtoolbar


% --------------------------------------------------------------------
function load_prefs(hfigure)
% Load the GUI preferences.  Also, initialize preferences if they don't
% already exist.

% Preferences:
% 'ascii'                Path and filenames of current ASCII files
% 'mat'                  Path and filename of current MAT file
% 'tecplot'              Path and filename of last Tecplot file
% 'kmz'                  Path and filename of last KMZ file
% 'multibeambathymetry'  Path and filename of last Multibeam Bathymetry file
% 'log'                  Path and filename of last Log file 
% 'iric'                 Path and filename of last iRic ANV file 

% Originals
% prefs = {'ascii2gispath' 'ascii2kmlpath' 'asciipath'   'doqqpath' ...
%          'endspath'      'logpath'       'matpath'     'savedpath' ...
%          'shorepath'     'stapath'       'ysidatapath' 'ysidatapath'};

% ASCII
if ispref('VMT','ascii')
    ascii = getpref('VMT','ascii');
    if exist(ascii.path,'dir')
        guiprefs.ascii_path = ascii.path;
    else
        guiprefs.ascii_path = pwd;
    end
    does_exist = false(1,length(ascii.file));
    for k = 1:length(ascii.file) % Check each file one-by-one
        does_exist(k) = exist(fullfile(ascii.path,ascii.file{k}),'file');
    end
    if any(does_exist)
        guiprefs.ascii_file = ascii.file(does_exist);
    else
        guiprefs.ascii_file = {''};
    end
else % Initialize ASCII
    guiprefs.ascii_path = pwd;
    guiprefs.ascii_file = {''};
    
    ascii.path = pwd;
    ascii.file = {''};
    setpref('VMT','ascii',ascii)
end

% MAT
if ispref('VMT','mat')
    mat = getpref('VMT','mat');
    if exist(mat.path,'dir')
        guiprefs.mat_path = mat.path;
    else
        guiprefs.mat_path = pwd;
    end
    
    if iscell(mat.file)
        if exist(fullfile(mat.path,mat.file{1}),'file')
            guiprefs.mat_file = mat.file;
        else
            guiprefs.mat_file = '';
        end
    else
        if exist(fullfile(mat.path,mat.file),'file')
            guiprefs.mat_file = mat.file;
        else
            guiprefs.mat_file = '';
        end
    end
else % Initialize MAT
    guiprefs.mat_path = pwd;
    guiprefs.mat_file = '';
    
    mat.path = pwd;
    mat.file = '';
    setpref('VMT','mat',mat)
end

% TECPLOT
if ispref('VMT','tecplot')
    tecplot = getpref('VMT','tecplot');
    if exist(tecplot.path,'dir')
        guiprefs.tecplot_path = tecplot.path;
    else
        guiprefs.tecplot_path = pwd;
    end
    if exist(fullfile(tecplot.path,tecplot.file),'file')
        guiprefs.tecplot_file = tecplot.file;
    else
        guiprefs.tecplot_file = '';
    end
else % Initialize TECPLOT
    guiprefs.tecplot_path = pwd;
    guiprefs.tecplot_file = '';
    
    tecplot.path = pwd;
    tecplot.file = '';
    setpref('VMT','tecplot',tecplot)
end

% KMZ
if ispref('VMT','kmz')
    kmz = getpref('VMT','kmz');
    if exist(kmz.path,'dir')
        guiprefs.kmz_path = kmz.path;
    else
        guiprefs.kmz_path = pwd;
    end
    if exist(fullfile(kmz.path,kmz.file),'file')
        guiprefs.kmz_file = kmz.file;
    else
        guiprefs.kmz_file = '';
    end
else % Initialize KMZ
    guiprefs.kmz_path = pwd;
    guiprefs.kmz_file = '';
    
    kmz.path = pwd;
    kmz.file = '';
    setpref('VMT','kmz',kmz)
end

% MULTIBEAM BATHYMETRY
if ispref('VMT','multibeambathymetry')
    multibeambathymetry = getpref('VMT','multibeambathymetry');
    if exist(multibeambathymetry.path,'dir')
        guiprefs.multibeambathymetry_path = multibeambathymetry.path;
    else
        guiprefs.multibeambathymetry_path = pwd;
    end
    if exist(fullfile(multibeambathymetry.path,multibeambathymetry.file),'file')
        guiprefs.multibeambathymetry_file = multibeambathymetry.file;
    else
        guiprefs.multibeambathymetry_file = '';
    end
else % Initialize MULTIBEAM BATHYMETRY
    guiprefs.multibeambathymetry_path = pwd;
    guiprefs.multibeambathymetry_file = '';
    
    multibeambathymetry.path = pwd;
    multibeambathymetry.file = '';
    setpref('VMT','multibeambathymetry',multibeambathymetry)
end

% Log
if ispref('VMT','log')
    log = getpref('VMT','log');
    if exist(log.path,'dir')
        guiprefs.log_path = log.path;
    else
        guiprefs.log_path = pwd;
    end
    if exist(fullfile(log.path,log.file),'file')
        guiprefs.log_file = log.file;
    else
        guiprefs.log_file = '';
    end
else % Initialize Log
    guiprefs.log_path = pwd;
    guiprefs.log_file = '';
    
    log.path = pwd;
    log.file = '';
    setpref('VMT','log',log)
end

% iRic
if ispref('VMT','iric')
    iric = getpref('VMT','iric');
    if exist(iric.path,'dir')
        guiprefs.iric_path = iric.path;
    else
        guiprefs.iric_path = pwd;
    end
    if exist(fullfile(iric.path,iric.file),'file')
        guiprefs.iric_file = iric.file;
    else
        guiprefs.iric_file = '';
    end
else % Initialize Log
    guiprefs.iric_path = pwd;
    guiprefs.iric_file = '';
    
    iric.path = pwd;
    iric.file = '';
    setpref('VMT','iric',iric)
end

% guiprefs.presentation = true;
% guiprefs.print        = false;

% for k = 1:length(prefs)
%     newpref = '';
%     if ispref('VMT',prefs{k})
%         stored_newpref = getpref('VMT',prefs{k});
%         if exist(stored_newpref,'dir')
%             newpref = stored_newpref;
%         else
%             setpref('VMT',prefs{k},newpref)
%         end
%     end
%     guiprefs.(prefs{k}) = newpref;
% end

setappdata(hfigure,'guiprefs',guiprefs)

% [EOF] load_prefs


% --------------------------------------------------------------------
function store_prefs(hfigure,pref)
% Store preferences in the Application data and in the persistent
% preferences data.

% Preferences:
% 'ascii'               Path and filenames of current ASCII files
% 'mat'                 Path and filename of current MAT file
% 'tecplot'             Path and filename of last Tecplot file
% 'kmz'                 Path and filename of last KMZ file
% 'multibeambathymetry' Path and filename of last Multibeam Bathymetry file
% 'log'                 Path and filename of last Log file 

guiprefs = getappdata(hfigure,'guiprefs');

switch pref
    case 'ascii'
        ascii.path = guiprefs.ascii_path;
        ascii.file = guiprefs.ascii_file;
        setpref('VMT','ascii',ascii)
    case 'mat'
        mat.path = guiprefs.mat_path;
        mat.file = guiprefs.mat_file;
        setpref('VMT','mat',mat)
    case 'tecplot'
        tecplot.path = guiprefs.tecplot_path;
        tecplot.file = guiprefs.tecplot_file;
        setpref('VMT','tecplot',tecplot)
    case 'kmz'
        kmz.path = guiprefs.kmz_path;
        kmz.file = guiprefs.kmz_file;
        setpref('VMT','kmz',kmz)
    case 'multibeambathymetry'
        multibeambathymetry.path = guiprefs.multibeambathymetry_path;
        multibeambathymetry.file = guiprefs.multibeambathymetry_file;
        setpref('VMT','multibeambathymetry',multibeambathymetry)
    case 'log'
        log.path = guiprefs.log_path;
        log.file = guiprefs.log_file;
        setpref('VMT','log',log)
    otherwise
end

% if ismember(pref,prefs)
%     setpref('VMT',pref,value)
%
%     guiprefs = getappdata(hfigure,'guiprefs');
%     guiprefs.(pref) = value;
%     setappdata(hfigure,'guiprefs',guiprefs)
% end

% [EOF] store_prefs


% --------------------------------------------------------------------
function initGUI(handles)
% Initialize the UI controls in the GUI.

guiparams = getappdata(handles.figure1,'guiparams');

% Set the name and version
set(handles.figure1,'Name',['Velocity Mapping Toolbox (VMT) ' guiparams.vmt_version], ...
    'DockControls','off')
%set(handles.VMTversion,             'String',guiparams.vmt_version)

% Set the PLOT 1 axis labels
axes(handles.Plot1Shiptracks);
set(handles.Plot1Shiptracks,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
box on
grid on
% ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM

%%%%%%%%%%%%
% MENU BAR %
%%%%%%%%%%%%
if guiparams.english_units
    set(handles.menuMetric, 'Checked','off')
    set(handles.menuEnglish,'Checked','on')
else
    set(handles.menuMetric, 'Checked','on')
    set(handles.menuEnglish,'Checked','off')
end

if guiparams.set_cross_section_endpoints
    set(handles.menuCrossSectionEndpointAutomatic,'Checked','off')
    set(handles.menuCrossSectionEndpointManual,   'Checked','on')
else
    set(handles.menuCrossSectionEndpointAutomatic,'Checked','on')
    set(handles.menuCrossSectionEndpointManual,   'Checked','off')
end


if guiparams.print
    set(handles.menuPrintFormat,       'Checked','on')
    set(handles.menuPresentationFormat,'Checked','off')
    set(handles.menuStylePrint,        'Checked','on')
    set(handles.menuStylePresentation, 'Checked','off')
elseif guiparams.presentation
    set(handles.menuPrintFormat,       'Checked','off')
    set(handles.menuPresentationFormat,'Checked','on')
    set(handles.menuStylePrint,        'Checked','off')
    set(handles.menuStylePresentation, 'Checked','on')
else
end


%%%%%%%%%%%%%%%
% DATA EXPORT %
%%%%%%%%%%%%%%%
% BathymetryPanel
% set(handles.BeamAngle,                  'String',guiparams.beam_angle)
% set(handles.MagneticVariation,          'String',guiparams.magnetic_variation)
% set(handles.WSE,                        'String',guiparams.wse)
% set(handles.OutputAuxiliaryData,        'Value', guiparams.output_auxiliary_data)

%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/PLAN VIEW %
%%%%%%%%%%%%%%%%%%%%%%
% PlanViewPanel
set(handles.DepthRangeMin,              'String',guiparams.depth_range_min)
set(handles.DepthRangeMax,              'String',guiparams.depth_range_max)
set(handles.VectorScalePlanView,        'String',guiparams.vector_scale_plan_view)
set(handles.VectorSpacingPlanview,      'String',guiparams.vector_spacing_plan_view)
set(handles.SmoothingWindowSize,        'String',guiparams.smoothing_window_size)
set(handles.MapDepthAveragedVelocities, 'Value', guiparams.map_depth_averaged_velocities)
set(handles.DisplayShoreline,           'Value', guiparams.display_shoreline)
set(handles.AddBackground,              'Value', guiparams.add_background)

%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/SHIP TRACKS %
%%%%%%%%%%%%%%%%%%%%%%%%
% ShiptracksPanel
set(handles.HorizontalGridNodeSpacing,  'String',guiparams.horizontal_grid_node_spacing)
%set(handles.SetCrossSectionEndpoints,   'Value', guiparams.set_cross_section_endpoints)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING/CROSS SECTIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CrossSectionsPanel
set(handles.Contour,                    'String',{guiparams.contours.string}, ...
    'Value', guiparams.idx_contour)
set(handles.VerticalExaggeration,       'String',guiparams.vertical_exaggeration)
set(handles.VectorScaleCrossSection,    'String',guiparams.vector_scale_cross_section)
set(handles.HorizontalVectorSpacing,    'String',guiparams.horizontal_vector_spacing)
set(handles.VerticalVectorSpacing,      'String',guiparams.vertical_vector_spacing)
set(handles.HorizontalSmoothingWindow,  'String',guiparams.horizontal_smoothing_window)
set(handles.VerticalSmoothingWindow,    'String',guiparams.vertical_smoothing_window)
set(handles.PlotSecondaryFlowVectors,   'Value', guiparams.plot_secondary_flow_vectors)
set(handles.SecondaryFlowVectorVariable,'String',{guiparams.secondary_flows.string}, ...
    'Value', guiparams.idx_secondary_flow_vector_variable)
set(handles.IncludeVerticalVelocity,    'Value', guiparams.include_vertical_velocity)

% set(handles.EnglishUnits,               'Value',guiparams.english_units)

% [EOF] initGUI


% --------------------------------------------------------------------
function set_enable(handles,enable_state)

guiparams = getappdata(handles.figure1,'guiparams');

switch enable_state
    case 'init'
        set([handles.menuFile
            handles.menuOpen
            handles.menuOpenASCII
            handles.menuOpenMAT
            ],'Enable','on')
%         set([handles.menuSave
%             handles.menuParameters
%             ],'Enable','off')
        
        set([handles.toolbarLoadData
            ],'Enable','on')
        set([handles.toolbarSaveMatFile
            handles.toolbarSaveBathymetry
            handles.toolbarSaveFigures
            handles.toolbarPlottingParameters
            handles.toolbarProcessingParameters
            ],'Enable','off')
        
        %         set([handles.SaveMATFile
        %              handles.SaveTecplotFile
        %              handles.SaveGoogleEarthFile
        %              ],'Enable','off')
        
        %         set([handles.ExportMultibeamBathymetry
        %              handles.BeamAngle
        %              handles.MagneticVariation
        %              handles.WSE
        %              handles.OutputAuxiliaryData
        %              ],'Enable','off')
        
        set([handles.DepthRangeMin
            handles.DepthRangeMax
            handles.VectorScalePlanView
            handles.VectorSpacingPlanview
            handles.SmoothingWindowSize
            handles.MapDepthAveragedVelocities
            handles.DisplayShoreline
            handles.AddBackground
            handles.PlotPlanView
            ],'Enable','off')
        
        set([handles.HorizontalGridNodeSpacing
            ...handles.SetCrossSectionEndpoints
            handles.PlotShiptracks
            ],'Enable','off')
        
        set([handles.Contour
            handles.VerticalExaggeration
            handles.VectorScaleCrossSection
            handles.HorizontalVectorSpacing
            handles.VerticalVectorSpacing
            handles.HorizontalSmoothingWindow
            handles.VerticalSmoothingWindow
            handles.PlotSecondaryFlowVectors
            handles.SecondaryFlowVectorVariable
            handles.IncludeVerticalVelocity
            handles.PlotCrossSection
            ],'Enable','off')
        
    case 'fileloaded'
        set([handles.menuFile
            handles.menuOpen
            handles.menuOpenASCII
            handles.menuOpenMAT
            ...handles.menuSave
            handles.menuSaveMAT
            handles.menuSaveTecplot
            handles.menuSaveKMZFile
            handles.menuParameters
            handles.menuPlottingParameters
            handles.menuMetric
            handles.menuEnglish
            handles.menuBathymetryExportSettings
            handles.menuExportMultibeamBathymetry
            handles.menuKMZExport
            ],'Enable','on')
        
        set([handles.toolbarLoadData
            handles.toolbarSaveMatFile
            handles.toolbarSaveBathymetry
            handles.toolbarSaveFigures
            handles.toolbarPlottingParameters
            ],'Enable','on')
        set([handles.toolbarProcessingParameters
            ],'Enable','off')
        
           
        set([handles.DepthRangeMin
            handles.DepthRangeMax
            handles.VectorScalePlanView
            handles.VectorSpacingPlanview
            handles.SmoothingWindowSize
            handles.MapDepthAveragedVelocities
            handles.DisplayShoreline
            handles.PlotPlanView
            ],'Enable','on')
        if guiparams.has_mapping_toolbox
            set(handles.AddBackground,'Enable','on')
        else
            set(handles.AddBackground,'Enable','off')
        end
        
        set([handles.HorizontalGridNodeSpacing
            ...handles.SetCrossSectionEndpoints
            handles.PlotShiptracks
            ],'Enable','on')
        
        set([handles.Contour
            handles.VerticalExaggeration
            handles.VectorScaleCrossSection
            handles.HorizontalVectorSpacing
            handles.VerticalVectorSpacing
            handles.HorizontalSmoothingWindow
            handles.VerticalSmoothingWindow
            handles.PlotSecondaryFlowVectors
            handles.SecondaryFlowVectorVariable
            handles.IncludeVerticalVelocity
            handles.PlotCrossSection
            ],'Enable','on')
    case 'multiplematfiles'
        set([handles.menuFile
            handles.menuOpen
            handles.menuOpenASCII
            handles.menuOpenMAT
            handles.menuParameters
            handles.menuPlottingParameters
            handles.menuMetric
            handles.menuEnglish
            ],'Enable','on')
        set([handles.menuSave
            handles.menuSaveMAT
            handles.menuBathymetryExportSettings
            handles.menuExportMultibeamBathymetry
            handles.menuKMZExport
            ],'Enable','off')
        
        set([handles.toolbarLoadData
            handles.toolbarSaveFigures
            handles.toolbarPlottingParameters
            ],'Enable','on')
        set([handles.toolbarProcessingParameters
            handles.toolbarSaveMatFile
            handles.toolbarSaveBathymetry
            ],'Enable','off')
        
        set([handles.DepthRangeMin
            handles.DepthRangeMax
            handles.VectorScalePlanView
            handles.VectorSpacingPlanview
            handles.SmoothingWindowSize
            handles.MapDepthAveragedVelocities
            handles.DisplayShoreline
            handles.PlotPlanView
            ],'Enable','on')
        if guiparams.has_mapping_toolbox
            set(handles.AddBackground,'Enable','on')
        else
            set(handles.AddBackground,'Enable','off')
        end
        
        set([handles.HorizontalGridNodeSpacing
            ...handles.SetCrossSectionEndpoints
            handles.PlotShiptracks
            ],'Enable','off')
        
        set([handles.Contour
            handles.VerticalExaggeration
            handles.VectorScaleCrossSection
            handles.HorizontalVectorSpacing
            handles.VerticalVectorSpacing
            handles.HorizontalSmoothingWindow
            handles.VerticalSmoothingWindow
            handles.PlotSecondaryFlowVectors
            handles.SecondaryFlowVectorVariable
            handles.IncludeVerticalVelocity
            handles.PlotCrossSection
            ],'Enable','off')
    otherwise
end

% Temporary
set(handles.MapDepthAveragedVelocities,'Value',0,'Enable','off')

% [EOF] set_enable

%% Compute the longitudinal dispersion coefficient

%% --- Executes on button press in zerosecq_chkbox.
%function zerosecq_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to zerosecq_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zerosecq_chkbox


% --------------------------------------------------------------------
function [english_units,set_cross_section_endpoints,plot_presentation_style,plot_print_style] = ...
    plotParametersDialog(english_units,set_cross_section_endpoints,plot_presentation_style,plot_print_style,hf)

w = 500;
h = 110;
dx = 10;
dy = 35;
the_color = get(0,'factoryUipanelBackgroundColor');
handles.Figure = figure('Name', 'Plotting Parameters', ...
    'Color',the_color, ...
    'NumberTitle','off', ...
    'HandleVisibility','callback', ...
    'WindowStyle','modal', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'Units','pixels', ...
    'Position',[0 0 w h], ...
    'Resize','off', ...
    'Visible','off');
dialog_params.english_units               = english_units;
dialog_params.set_cross_section_endpoints = set_cross_section_endpoints;
dialog_params.presentation                = plot_presentation_style; %presentation;
dialog_params.print                       = plot_print_style; %print;
setappdata(handles.Figure,'dialog_params',dialog_params)
setappdata(handles.Figure,'original_dialog_params',dialog_params)

% Build the graphics:
% -------------------
handles.UnitsPanel = uipanel('Parent',handles.Figure, ...
    'Title', 'Units', ...
    'Units','pixels', ...
    'Position',[dx dy (w-3*dx)/3 h-dx-dy+10]);
handles.UnitsMetric = uicontrol('Style','checkbox', ...
    'Parent',handles.UnitsPanel, ...
    'String','Metric', ...
    'Units','pixels', ...
    'Position',[15 35 100 22]);
handles.UnitsEnglish = uicontrol('Style','checkbox', ...
    'Parent',handles.UnitsPanel, ...
    'String','English', ...
    'Units','pixels', ...
    'Position',[15 10 100 22]);

handles.EndpointsPanel = uipanel('Parent',handles.Figure, ...
    'Title', 'Cross-Section Endpoints', ...
    'Units','pixels', ...
    'Position',[(w+dx)/3 dy (w-3*dx)/3 h-dx-dy+10]);
handles.EndpointsAutomatic = uicontrol('Style','checkbox', ...
    'Parent',handles.EndpointsPanel, ...
    'String','Automatic', ...
    'Units','pixels', ...
    'Position',[15 35 100 22]);
handles.EndpointsManual = uicontrol('Style','checkbox', ...
    'Parent',handles.EndpointsPanel, ...
    'String','Set Manually', ...
    'Units','pixels', ...
    'Position',[15 10 100 22]);

handles.StylePanel = uipanel('Parent',handles.Figure, ...
    'Title', 'Plot Style', ...
    'Units','pixels', ...
    'Position',[w-w/3 dy (w-3*dx)/3 h-dx-dy+10]);
handles.StylePresentation = uicontrol('Style','checkbox', ...
    'Parent',handles.StylePanel, ...
    'String','Presentation', ...
    'Units','pixels', ...
    'Position',[15 35 100 22]);
handles.StylePrint = uicontrol('Style','checkbox', ...
    'Parent',handles.StylePanel, ...
    'String','Print', ...
    'Units','pixels', ...
    'Position',[15 10 100 22]);

handles.OK = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'OK', ...
    'Units',   'pixels', ...
    'Position',[w/2-80-dx/4 6 80 22]);
handles.Cancel = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'Cancel', ...
    'Units',   'pixels', ...
    'Position',[w/2+dx/4 6 80 22]);

% Update the UI controls:
% -----------------------
if dialog_params.english_units
    set(handles.UnitsMetric, 'Value',0)
    set(handles.UnitsEnglish,'Value',1)
else
    set(handles.UnitsMetric, 'Value',1)
    set(handles.UnitsEnglish,'Value',0)
end
if dialog_params.set_cross_section_endpoints
    set(handles.EndpointsAutomatic,'Value',0)
    set(handles.EndpointsManual,   'Value',1)
else
    set(handles.EndpointsAutomatic,'Value',1)
    set(handles.EndpointsManual,   'Value',0)
end
if dialog_params.presentation
    set(handles.StylePresentation, 'Value',1)
    set(handles.StylePrint,        'Value',0)
else
    set(handles.StylePresentation, 'Value',0)
    set(handles.StylePrint,        'Value',1)
end

% Set the callbacks:
% ------------------
set(handles.Figure,            'CloseRequestFcn',{@dialogCloseReq,handles.OK})
set(handles.UnitsMetric,       'Callback',       {@dialogUnits,    handles,'metric'})
set(handles.UnitsEnglish,      'Callback',       {@dialogUnits,    handles,'english'})
set(handles.EndpointsAutomatic,'Callback',       {@dialogEnpoints, handles,'auto'})
set(handles.EndpointsManual,   'Callback',       {@dialogEnpoints, handles,'manual'})
set(handles.StylePresentation, 'Callback',       {@dialogPlotStyle,handles,'presentation'})
set(handles.StylePrint,        'Callback',       {@dialogPlotStyle,handles,'print'})
set(handles.OK,                'Callback',       {@dialogOK,       handles.OK})
set(handles.Cancel,            'Callback',       {@dialogCancel,   handles})

% Position the dialog and make it visible:
% ----------------------------------------
fpos = get(hf,'Position');
dpos = [(fpos(1) + fpos(3)/2 -w/2) (fpos(2) + fpos(4)/2)];
movegui(handles.Figure,dpos)
set(handles.Figure,'Visible','on')

% Hold the dialog open:
% ---------------------
waitfor(handles.OK)

% Return the outputs and close the dialog:
% ----------------------------------------
dialog_params = getappdata(handles.Figure,'dialog_params');
english_units = dialog_params.english_units;
set_cross_section_endpoints = dialog_params.set_cross_section_endpoints;
plot_presentation_style =  dialog_params.presentation;
plot_print_style =  dialog_params.print;

delete(handles.Figure)

% [EOF] plotParametersDialog


% --------------------------------------------------------------------
function dialogUnits(hObject,eventdata,handles,the_units)

dialog_params = getappdata(handles.Figure,'dialog_params');
switch the_units
    case 'metric'
        dialog_params.english_units = false;
        
        set(handles.UnitsMetric, 'Value',1)
        set(handles.UnitsEnglish,'Value',0)
    case 'english'
        dialog_params.english_units = true;
        
        set(handles.UnitsMetric, 'Value',0)
        set(handles.UnitsEnglish,'Value',1)
    otherwise
end
setappdata(handles.Figure,'dialog_params',dialog_params)

% [EOF] dialogUnits

% --------------------------------------------------------------------
function dialogEnpoints(hObject,eventdata,handles,the_endpoints)

dialog_params = getappdata(handles.Figure,'dialog_params');
switch the_endpoints
    case 'auto'
        dialog_params.set_cross_section_endpoints = false;
        
        set(handles.EndpointsAutomatic,'Value',1)
        set(handles.EndpointsManual,   'Value',0)
    case 'manual'
        dialog_params.set_cross_section_endpoints = true;
        
        set(handles.EndpointsAutomatic,'Value',0)
        set(handles.EndpointsManual,   'Value',1)
    otherwise
end
setappdata(handles.Figure,'dialog_params',dialog_params)

% [EOF] dialogEnpoints

function dialogPlotStyle(hObject,eventdata,handles,the_style)

dialog_params = getappdata(handles.Figure,'dialog_params');
switch the_style
    case 'presentation'
        dialog_params.presentation  = true;
        dialog_params.print         = false;
        
        set(handles.StylePresentation,'Value',1)
        set(handles.StylePrint,       'Value',0)
    case 'print'
        dialog_params.presentation  = false;
        dialog_params.print         = true;
        
        set(handles.StylePresentation,'Value',0)
        set(handles.StylePrint,       'Value',1)
    otherwise
end
setappdata(handles.Figure,'dialog_params',dialog_params)

% [EOF] dialogEnpoints

% --------------------------------------------------------------------
function dialogOK(hObject,eventdata,h_OK)

delete(h_OK)

% [EOF] dialogOK

% --------------------------------------------------------------------
function dialogCancel(hObject,eventdata,handles)
% Return the original inputs
dialog_params = getappdata(handles.Figure,'original_dialog_params');
setappdata(handles.Figure,'dialog_params',dialog_params)
delete(handles.OK)

% [EOF] dialogCancel

% --------------------------------------------------------------------
function dialogCloseReq(hObject,eventdata,h_OK)

delete(h_OK)

% [EOF] dialogCloseReq

function [beam_angle,magnetic_variation,wse,output_auxilliary_data] = exportSettingsDialog(beam_angle,magnetic_variation,wse,output_auxilliary_data,hf)
w = 230;
h = 200;
dx = 10;
dy = 35;
the_color = get(0,'factoryUipanelBackgroundColor');
handles.Figure = figure('Name', 'Export Settings', ...
    'Color',the_color, ...
    'NumberTitle','off', ...
    'HandleVisibility','callback', ...
    'WindowStyle','modal', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'Units','pixels', ...
    'Position',[0 0 w h], ...
    'Resize','off', ...
    'Visible','off');
dialog_params.beam_angle             = beam_angle;
dialog_params.magnetic_variation     = magnetic_variation;
dialog_params.wse                    = wse;
dialog_params.output_auxilliary_data = output_auxilliary_data;
setappdata(handles.Figure,'dialog_params',dialog_params)
setappdata(handles.Figure,'original_dialog_params',dialog_params)

% Build the graphics:
% -------------------
ph = 150;
handles.BathymetryPanel = uipanel('Parent',handles.Figure, ...
    'Title', 'Bathymetry', ...
    'Units','pixels', ...
    'Position',[dx dy (w-2*dx) h-dx-dy+10]);
handles.BeamAngleText = uicontrol('Style','text', ...
    'Parent',handles.BathymetryPanel, ...
    'String','Beam Angle (deg)', ...
    ...'Value',beam_angle,...
    'HorizontalAlignment','right',...
    'Units','pixels', ...
    'Position',[dx+5 h-ph+60-4 100 22]);
handles.BeamAngle = uicontrol('Style','edit', ...
    'Parent',handles.BathymetryPanel, ...
    ...'String','Beam Angle (deg)', ...
    'String',beam_angle,...
    'BackgroundColor','w',...
    'Units','pixels', ...
    'Position',[w-dx-80 h-ph+60 50 22]);
handles.MagneticVariationText = uicontrol('Style','text', ...
    'Parent',handles.BathymetryPanel, ...
    'String','Magnetic Variation', ...
    ...'Value',beam_angle,...
    'HorizontalAlignment','right',...
    'Units','pixels', ...
    'Position',[dx+5 h-ph+30-4 100 22]);
handles.MagneticVariation = uicontrol('Style','edit', ...
    'Parent',handles.BathymetryPanel, ...
    ...'String','Magnetic Variation', ...
    'String',magnetic_variation,...
    'BackgroundColor','w',...
    'Units','pixels', ...
    'Position',[w-dx-80 h-ph+30 50 22]);
handles.WSEText = uicontrol('Style','text', ...
    'Parent',handles.BathymetryPanel, ...
    'String','WSE (m)', ...
    ...'Value',beam_angle,...
    'HorizontalAlignment','right',...
    'Units','pixels', ...
    'Position',[dx+5 h-ph-4 100 22]);
handles.WSE = uicontrol('Style','edit', ...
    'Parent',handles.BathymetryPanel, ...
    ...'String','Magnetic Variation', ...
    'String',wse,...
    'BackgroundColor','w',...
    'Units','pixels', ...
    'Position',[w-dx-80 h-ph 50 22]);
handles.OutputAuxilliaryData = uicontrol('Style','checkbox', ...
    'Parent',handles.BathymetryPanel, ...
    'String','Output Auxilliary Data', ...
    'Units','pixels', ...
    'Position',[dx+5 20 w-2*dx-30 22]);
handles.OK = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'OK', ...
    'Units',   'pixels', ...
    'Position',[w/2-80-dx/4 6 80 22]);
handles.Cancel = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'Cancel', ...
    'Units',   'pixels', ...
    'Position',[w/2+dx/4 6 80 22]);

% Update the UI controls:
% -----------------------
set(handles.BeamAngle,                'String',dialog_params.beam_angle)
set(handles.MagneticVariation,        'String',dialog_params.magnetic_variation)
set(handles.WSE,                      'String',dialog_params.wse)
set(handles.OutputAuxilliaryData,     'Value',dialog_params.output_auxilliary_data)

% Set the callbacks:
% ------------------
set(handles.Figure,                      'CloseRequestFcn',{@dialogCloseReq,handles.OK})
set(handles.BeamAngle,                   'Callback',       {@dialogExportSettings,handles})
set(handles.MagneticVariation,           'Callback',       {@dialogExportSettings,handles})
set(handles.WSE,                         'Callback',       {@dialogExportSettings,handles})
set(handles.OutputAuxilliaryData,        'Callback',       {@dialogExportSettings,handles})
set(handles.OK,                          'Callback',       {@dialogOK,      handles.OK})
set(handles.Cancel,                      'Callback',       {@dialogCancel,  handles})

% Position the dialog and make it visible:
% ----------------------------------------
fpos = get(hf,'Position');
dpos = [(fpos(1) + fpos(3)/2 -w/2) (fpos(2) + fpos(4)/2)];
movegui(handles.Figure,dpos)
set(handles.Figure,'Visible','on')

% Hold the dialog open:
% ---------------------
waitfor(handles.OK)

% Return the outputs and close the dialog:
% ----------------------------------------
dialog_params           = getappdata(handles.Figure,'dialog_params');
beam_angle              = dialog_params.beam_angle;
magnetic_variation      = dialog_params.magnetic_variation;
wse                     = dialog_params.wse;
output_auxilliary_data  = dialog_params.output_auxilliary_data;

delete(handles.Figure)

% [EOF] exportSettingsDialog

% --------------------------------------------------------------------
function dialogExportSettings(hObject,eventdata,handles)

% Grab the current data
dialog_params = getappdata(handles.Figure,'dialog_params');

% Set it according to the dialog box values
dialog_params.beam_angle                = get(handles.BeamAngle,'String');
dialog_params.magnetic_variation        = get(handles.MagneticVariation,'String');
dialog_params.wse                       = get(handles.WSE,'String');
dialog_params.output_auxilliary_data    = get(handles.OutputAuxilliaryData,'Value');

% Re-store the application data
setappdata(handles.Figure,'dialog_params',dialog_params)

% [EOF] dialogExportSettings

function [selected_figures] = openFiguresDialog(figure_names,hf)

w = 230;
h = 200;
dx = 10;
dy = 35;
the_color = get(0,'factoryUipanelBackgroundColor');
handles.Figure = figure('Name', 'Select open figures to export', ...
    'Color',the_color, ...
    'NumberTitle','off', ...
    'HandleVisibility','callback', ...
    'WindowStyle','modal', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'Units','pixels', ...
    'Position',[0 0 w h], ...
    'Resize','off', ...
    'Visible','off');
dialog_params.figure_names               = figure_names;
dialog_params.selected_figures           = '';
setappdata(handles.Figure,'dialog_params',dialog_params)
setappdata(handles.Figure,'original_dialog_params',dialog_params)

% Build the graphics:
% -------------------
handles.ListboxPanel = uipanel('Parent',handles.Figure, ...
    'Title', 'Figures', ...
    'Units','pixels', ...
    'Position',[dx dy (w-2*dx) h-dx-dy+10]);
handles.Figures = uicontrol('Style','listbox', ...
    'Parent',handles.ListboxPanel, ...
    'BackGroundColor','white',...
    'String',figure_names, ...
    'Min', 0,...
    'Max', 2,...
    'Units','pixels', ...
    'Position',[15 35 (w-5*dx) 100]);


handles.OK = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'OK', ...
    'Units',   'pixels', ...
    'Position',[w/2-80-dx/4 6 80 22]);
handles.Cancel = uicontrol('Style',   'pushbutton', ...
    'Parent',  handles.Figure, ...
    'String',  'Cancel', ...
    'Units',   'pixels', ...
    'Position',[w/2+dx/4 6 80 22]);

% Update the UI controls:
% -----------------------


% Set the callbacks:
% ------------------
set(handles.Figure,            'CloseRequestFcn',{@dialogCloseReq,handles.OK})
set(handles.Figures,           'Callback',       {@dialogSelectFigures    handles})
set(handles.OK,                'Callback',       {@dialogOK,       handles.OK})
set(handles.Cancel,            'Callback',       {@dialogCancel,   handles})

% Position the dialog and make it visible:
% ----------------------------------------
fpos = get(hf,'Position');
dpos = [(fpos(1) + fpos(3)/2 -w/2) (fpos(2) + fpos(4)/2)];
movegui(handles.Figure,dpos)
set(handles.Figure,'Visible','on')

% Hold the dialog open:
% ---------------------
waitfor(handles.OK)

% Return the outputs and close the dialog:
% ----------------------------------------
dialog_params = getappdata(handles.Figure,'dialog_params');
selected_figures = dialog_params.selected_figures;

delete(handles.Figure)

% [EOF] openFiguresDialog

% --------------------------------------------------------------------
function dialogSelectFigures(hObject,eventdata,handles)

dialog_params = getappdata(handles.Figure,'dialog_params');

idx_selected = get(handles.Figures,'Value');
fig_names    = get(handles.Figures,'String');
selected     = fig_names(idx_selected);
dialog_params.selected_figures = selected;

setappdata(handles.Figure,'dialog_params',dialog_params)



% --------------------------------------------------------------------
function icons = getIcons

% Load data
idx = 1;
icons(idx).data(:,:,1) = ...
    [NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   129   120   135   188   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN    96   189   NaN   NaN   130   NaN    95   NaN
    NaN   NaN   206   206   206   206   NaN   NaN   NaN   NaN   NaN   NaN   NaN    84    79   NaN
    NaN   206   255   255   255   255   198   197   NaN   NaN   NaN   NaN    83    79    76   NaN
    198   255   255   255   255   255   255   198   198   198   198   198   198   212   212   NaN
    198   255   255   255   255   255   255   255   255   255   255   255   198   157   197   NaN
    198   255   226   198   198   198   198   198   198   198   198   198   198   198   177   NaN
    198   255   198   218   255   255   255   255   255   255   255   255   255   255   161   NaN
    198   253   198   247   255   255   255   255   255   255   255   255   255   251   155   NaN
    198   226   201   255   255   255   255   255   255   255   255   255   231   206   165   NaN
    198   207   215   255   255   255   255   255   255   255   255   255   239   198   159   NaN
    198   198   240   255   255   255   255   255   255   255   255   255   222   157   159   NaN
    198   199   255   255   255   255   255   255   255   255   255   255   191   165   159   NaN
    NaN   165   165   165   165   165   165   165   165   165   165   165   165   159   159   NaN
    NaN   NaN   159   159   159   159   159   159   159   159   159   159   159   159   NaN   NaN]/255;

icons(idx).data(:,:,2) = ...
    [NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   145   137   149   195   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   116   196   NaN   NaN   145   NaN   116   NaN
    NaN   NaN   162   162   162   162   NaN   NaN   NaN   NaN   NaN   NaN   NaN   107   105   NaN
    NaN   162   255   255   255   255   154   197   NaN   NaN   NaN   NaN   106   104   103   NaN
    154   255   255   255   255   255   255   154   154   154   154   154   154   208   208   NaN
    154   243   243   243   243   243   243   255   255   255   255   255   154   123   197   NaN
    154   235   193   154   154   154   154   154   154   154   154   154   154   154   137   NaN
    154   215   154   191   255   255   251   255   255   255   255   255   231   255   126   NaN
    154   213   154   240   255   255   255   255   255   255   255   255   199   249   123   NaN
    154   179   160   255   247   247   247   247   247   247   247   247   190   188   115   NaN
    154   162   184   255   235   235   235   235   235   235   235   231   186   154   169   NaN
    154   154   228   255   227   227   227   227   227   227   227   223   178   123   169   NaN
    154   156   255   215   215   215   215   215   215   215   215   215   153   115   169   NaN
    NaN   115   115   115   115   115   115   115   115   115   115   115   115   169   169   NaN
    NaN   NaN   169   169   169   169   169   169   169   169   169   169   169   169   NaN   NaN]/255;

icons(idx).data(:,:,3) = ...
    [NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   166   161   170   202   NaN   NaN   NaN
    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   149   205   NaN   NaN   166   NaN   148   NaN
    NaN   NaN    34    34    34    34   NaN   NaN   NaN   NaN   NaN   NaN   NaN   141   144   NaN
    NaN    34   255   255   255   255    25   197   NaN   NaN   NaN   NaN   142   145   147   NaN
    25   255   156   156   156   156   255    25    25    25    25    25    25   200   200   NaN
    25   156   140   140   140   140   140   255   255   255   255   255    25    26   197   NaN
    25   132    80    25    25    25    25    25    25    25    25    25    25    25    25   NaN
    25   132    25   108   255   255   247   255   255   255   255   255   132   255    25   NaN
    25   112    25   137   156   156   156   156   156   156   156   156    91   150    25   NaN
    25    67    33   165   148   148   148   148   148   148   148   148    83    92    13   NaN
    25    38    64   156   132   132   132   132   132   132   132   132    67    25   176   NaN
    25    26   122   156   124   124   124   124   124   124   124   124    67    26   176   NaN
    25    28   156   108   108   108   108   108   108   108   108   108    41    13   176   NaN
    NaN    13    13    13    13    13    13    13    13    13    13    13    13   176   176   NaN
    NaN   NaN   176   176   176   176   176   176   176   176   176   176   176   176   NaN   NaN]/255;

% Save data
idx = idx+1;
icons(idx).data(:,:,1) = ...
    [NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN
    NaN    0.6902    0.6902    0.6902    0.6902    0.6902    0.6274    0.6274    0.5647    0.5647    0.5647    0.5019    0.5019    0.4392    0.2510       NaN
    NaN    0.6902    0.7529    0.5647    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.3137    0.3765    0.2510    0.4670
    NaN    0.6902    0.7529    0.5647    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.2510    0.1882    0.2510    0.4670
    NaN    0.6274    0.7529    0.5019    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.8784    0.1882    0.5019    0.2510    0.4670
    NaN    0.6274    0.7529    0.4392    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.8784    0.8157    0.1882    0.4392    0.2510    0.4670
    NaN    0.6274    0.7529    0.4392    1.0000    1.0000    1.0000    0.9412    0.9412    0.8784    0.8157    0.7529    0.1255    0.3765    0.2510    0.4670
    NaN    0.5647    0.7529    0.3765    1.0000    1.0000    0.9412    0.9412    0.8784    0.8157    0.7529    0.7529    0.0627    0.3765    0.2510    0.4670
    NaN    0.5647    0.7529    0.6902    0.3765    0.3137    0.3137    0.2510    0.1882    0.1882    0.1255    0.0627    0.3765    0.3137    0.2510    0.4670
    NaN    0.5019    0.6902    0.6902    0.6274    0.5647    0.5019    0.5019    0.5019    0.4392    0.4392    0.3765    0.3137    0.3137    0.2510    0.4670
    NaN    0.5019    0.6902    0.6274    0.5647    0.3137    0.3137    0.3137    0.3137    0.3137    0.3765    0.3137    0.3137    0.2510    0.2510    0.4670
    NaN    0.4392    0.6274    0.5647    0.5019    0.3137       NaN    0.1882    0.8157    0.8157    0.3765    0.2510    0.2510    0.2510    0.2510    0.4670
    NaN    0.4392    0.6274    0.5019    0.5019    0.3137    0.1882    0.4392    0.8784    0.8784    0.4392    0.1882    0.2510    0.1882    0.2510    0.4670
    NaN    0.4392    0.5647    0.5019    0.1255    0.1255    0.6902    0.6902    0.7529    0.7529    0.3137    0.1882    0.1882    0.1882    0.2510    0.4670
    NaN    0.7333    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.2510    0.4670
    NaN       NaN    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670    0.4670];

icons(idx).data(:,:,2) = ...
    [NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN
    NaN    0.7216    0.7216    0.6902    0.6902    0.6588    0.6274    0.5961    0.5647    0.5647    0.5333    0.5019    0.4706    0.4706    0.2196       NaN
    NaN    0.6902    0.7529    0.5647    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9725    0.3451    0.3451    0.2196    0.5378
    NaN    0.6902    0.7529    0.5333    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9725    0.9412    0.3137    0.1882    0.2196    0.5378
    NaN    0.6588    0.7529    0.5019    1.0000    1.0000    1.0000    1.0000    1.0000    0.9725    0.9412    0.9098    0.3137    0.4706    0.2196    0.5378
    NaN    0.6274    0.7529    0.4706    1.0000    1.0000    1.0000    1.0000    0.9725    0.9412    0.9098    0.8470    0.2824    0.4392    0.2196    0.5378
    NaN    0.5961    0.7529    0.4392    1.0000    1.0000    1.0000    0.9725    0.9412    0.9098    0.8470    0.8157    0.2510    0.4078    0.2196    0.5378
    NaN    0.5647    0.7529    0.4078    1.0000    1.0000    0.9725    0.9412    0.9098    0.8470    0.8157    0.7843    0.2196    0.3765    0.2196    0.5378
    NaN    0.5333    0.7216    0.7216    0.3765    0.3765    0.3451    0.3137    0.3137    0.2824    0.2510    0.2196    0.3765    0.3451    0.2196    0.5378
    NaN    0.5019    0.6902    0.6902    0.6274    0.5647    0.5333    0.5019    0.4706    0.4392    0.4078    0.3765    0.3451    0.3137    0.2196    0.5378
    NaN    0.4706    0.6588    0.6274    0.5647    0.3451    0.3451    0.3451    0.3451    0.3765    0.4078    0.3451    0.3137    0.2824    0.2196    0.5378
    NaN    0.4706    0.6274    0.5647    0.5333    0.3451       NaN    0.2510    0.8470    0.8784    0.4706    0.2824    0.2824    0.2510    0.2196    0.5378
    NaN    0.4392    0.5961    0.5333    0.5019    0.3451    0.2510    0.4706    0.8784    0.9098    0.5019    0.2510    0.2510    0.2510    0.2196    0.5378
    NaN    0.4078    0.5647    0.5019    0.2824    0.1882    0.7216    0.7216    0.7529    0.7843    0.3137    0.2510    0.2510    0.2196    0.2196    0.5378
    NaN    0.7176    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.2196    0.5378
    NaN       NaN    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378    0.5378];

icons(idx).data(:,:,3) = ...
    [NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN
    NaN    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.8784    0.8784    0.8784    0.8784    0.8784    0.8157    0.8157    0.4392       NaN
    NaN    0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.7529    0.6902    0.4392    0.5997
    NaN    0.9412    1.0000    0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.7529    0.3765    0.4392    0.5997
    NaN    0.9412    1.0000    0.8784    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.6902    0.8784    0.4392    0.5997
    NaN    0.9412    1.0000    0.8784    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.6902    0.8157    0.4392    0.5997
    NaN    0.8784    1.0000    0.8157    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.8784    0.6274    0.8157    0.4392    0.5997
    NaN    0.8784    1.0000    0.8157    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.8784    0.8784    0.6274    0.7529    0.4392    0.5997
    NaN    0.8784    1.0000    1.0000    0.8157    0.7529    0.7529    0.7529    0.6902    0.6902    0.6274    0.6274    0.7529    0.7529    0.4392    0.5997
    NaN    0.8784    1.0000    1.0000    1.0000    0.9412    0.9412    0.8784    0.8784    0.8157    0.8157    0.7529    0.7529    0.6902    0.4392    0.5997
    NaN    0.8157    1.0000    1.0000    0.9412    0.4392    0.4392    0.4392    0.4392    0.4392    0.5019    0.7529    0.6902    0.6902    0.4392    0.5997
    NaN    0.8157    1.0000    0.9412    0.9412    0.4392       NaN    0.2510    0.9412    0.9412    0.5019    0.6902    0.6902    0.6274    0.4392    0.5997
    NaN    0.8157    1.0000    0.9412    0.8784    0.4392    0.2510    0.5647    0.9412    0.9412    0.5647    0.6274    0.6274    0.6274    0.4392    0.5997
    NaN    0.8157    0.9412    0.8784    0.6902    0.2510    0.7529    0.7529    0.8157    0.8157    0.3137    0.6274    0.6274    0.6274    0.4392    0.5997
    NaN    0.8275    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.4392    0.5997
    NaN       NaN    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997    0.5997];

% Plotting parameters
idx = idx+1;
icons(idx).data(:,:,1) = ...
    [  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   255
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   165
    0   255   203    79   213   255   255   255   255   255   254   160   109   247     0   165
    0   254    71   224    79   255   255   255   255   255   211   101   165   123     0   165
    0   191   123   255   123   203   255   255   255   255   101   224   254    79     0   165
    0   101   239   255   224   109   255   255   255   247    79   254   254   123    36   165
    0   123   254   255   255    79   247   255   255   165   165   255   255   224     0   165
    0   255   255   255   254   160   173   255   255    87   239   255   255   255     0   165
    0   255   255   255   255   224   101   255   239    87   255   255   255   255     0   165
    0   255   255   255   255   255   101   224   123   191   255   255   255   255     0   165
    0   255   255   255   255   254   224    54   101   255   255   255   255   255     0   165
    0   255   255   255   255   255   255   247   255   255   255   255   255   255     0   165
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   165
    0     0     0     1     0     0     0     0     0     0     0     0     0     0     0   165
    255   165   165   165   172   165   165   165   165   165   165   165   165   165   165   165]/255;

icons(idx).data(:,:,2) = ...
    [  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0     0
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   165
    0   255   203    79   213   255   255   255   255   255   254   160   109   247     0   165
    0   254    71   224    79   255   255   255   255   255   211   101   165   123     0   165
    0   191   123   255   123   203   255   255   255   255   101   224   254    79     0   165
    0   101   239   255   224   109   255   255   255   247    79   254   254   123     0   165
    0   123   254   255   255    79   247   255   255   165   165   255   255   224     0   165
    0   255   255   255   254   160   173   255   255    87   239   255   255   255     0   165
    0   255   255   255   255   224   101   255   239    87   255   255   255   255     0   165
    0   255   255   255   255   255   101   224   123   191   255   255   255   255     0   165
    0   255   255   255   255   254   224    54   101   255   255   255   255   255     0   165
    0   255   255   255   255   255   255   247   255   255   255   255   255   255     0   165
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   165
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   165
    0   165   165   165   153   165   165   165   165   165   165   165   165   165   165   165]/255;

icons(idx).data(:,:,3) = ...
    [  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   255
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0   255   255   255   255   255   255   255   255   255   255   255   255   255     0   145
    0    24    39     0     0     0     0     0     0     0     0     0     0     0     0   145
    255   145   145   145   134   145   145   145   145   145   145   145   145   145   145   145]/255;

% Processing parameters
idx = idx+1;
icons(idx).data(:,:,1) = ...
    [255   255   255   255   255   255   255   255   255   255   255   255   255   255   255   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   255   107   255   255   107   255   255   107   255   107   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   255   107   255   107   255   107   255   255   107   255   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   107   255   107   255   107   255   255   107   255   107   255     0   255
    255     0   255   255   107   255   255   107   255   255   255   107   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255]/255;

icons(idx).data(:,:,2) = ...
    [255   255   255   255   255   255   255   255   255   255   255   255   255   255   255   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255    99   255   255    99   255   255    99   255    99   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255    99   255    99   255    99   255   255    99   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255    99   255    99   255    99   255   255    99   255    99   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255]/255;

icons(idx).data(:,:,3) = ...
    [255   255   255   255   255   255   255   255   255   255   255   255   255   255   255   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255    99   255   255    99   255   255    99   255    99   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255    99   255    99   255    99   255   255    99   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255    99   255    99   255    99   255   255    99   255    99   255     0   255
    255     0   255   255    99   255   255    99   255   255   255    99   255   255     0   255
    255     0   255   255   255   255   255   255   255   255   255   255   255   255     0   255
    255     0     0     0   255   255   255   255   255   255   255   255     0     0     0   255]/255;

% Export bathymetry dialog
idx = idx+1;
icons(idx).data(:,:,1) = ...
    [226	226	226	226	226	226	226	197	220	226	226	226	226	226	226	226
    226	226	226	226	226	227	241	144	158	241	228	228	229	228	229	226
    226	243	243	243	237	237	246	164	119	242	232	225	226	218	243	206
    179	152	153	166	148	148	177	179	63	185	141	146	154	151	179	189
    167	4	134	175	151	164	161	198	122	255	212	233	215	199	140	185
    134	50	209	241	255	255	133	118	15	20	28	94	4	0	0	89
    136	0	0	0	0	0	0	0	0	0	0	0	0	21	56	140
    208	255	226	233	255	242	215	232	251	237	226	233	207	222	156	139
    172	159	152	153	166	145	178	147	169	164	161	163	154	153	128	135
    160	164	148	139	171	150	165	154	165	185	166	173	190	190	148	162
    214	233	211	203	217	212	217	238	202	236	213	222	230	224	184	184
    219	206	174	190	219	204	201	218	183	224	219	222	217	202	176	182
    210	182	183	214	225	220	203	229	175	217	220	220	222	212	184	185
    197	175	207	224	223	220	205	231	170	221	220	220	222	217	191	187
    186	193	223	224	220	201	203	228	171	224	218	220	222	215	190	187
    189	211	220	216	204	201	214	213	187	213	216	220	220	212	193	189
    ]/255;
icons(idx).data(:,:,2) = ...
    [233	233	233	233	233	233	233	204	227	233	233	233	233	233	233	233
    233	233	233	233	233	234	247	152	167	247	235	234	235	234	236	233
    233	242	242	240	236	237	247	170	131	243	234	231	234	224	245	212
    208	193	199	209	196	196	211	197	100	211	194	196	200	199	202	196
    205	19	179	199	183	197	182	179	162	255	217	246	234	231	191	199
    167	47	229	240	255	252	139	154	87	86	99	139	79	46	23	121
    175	30	47	29	28	19	5	41	33	39	54	55	65	83	81	185
    236	255	249	253	255	251	240	255	235	255	247	252	233	245	204	190
    208	200	195	196	204	192	214	202	144	215	201	201	195	195	177	186
    200	201	189	183	206	192	204	210	111	231	209	214	222	223	199	209
    245	255	251	247	254	254	252	255	156	255	254	255	255	254	235	232
    249	244	227	237	247	244	242	255	132	239	254	250	247	244	228	231
    245	231	231	246	253	249	243	255	119	223	255	251	250	245	229	232
    239	227	244	251	251	248	244	255	110	217	255	250	251	246	233	233
    233	237	250	252	249	242	246	255	115	209	255	250	251	246	232	232
    234	245	249	247	242	242	246	231	154	192	246	249	249	245	234	233
    ]/255;
icons(idx).data(:,:,3) = ...
    [233	233	233	233	233	233	233	204	227	233	233	233	233	233	233	233
    233	233	233	233	233	234	247	152	167	247	235	234	235	234	236	233
    233	242	242	240	236	237	247	170	131	243	234	231	234	224	245	212
    208	193	199	209	196	196	211	197	100	211	194	196	200	199	202	196
    205	19	179	199	183	197	182	179	162	255	217	246	234	231	191	199
    167	47	229	240	255	252	139	154	87	86	99	139	79	46	23	121
    175	30	47	29	28	19	5	41	33	39	54	55	65	83	81	185
    236	255	249	253	255	251	240	255	235	255	247	252	233	245	204	190
    208	200	195	196	204	192	214	202	144	215	201	201	195	195	177	186
    200	201	189	183	206	192	204	210	111	231	209	214	222	223	199	209
    245	255	251	247	254	254	252	255	156	255	254	255	255	254	235	232
    249	244	227	237	247	244	242	255	132	239	254	250	247	244	228	231
    245	231	231	246	253	249	243	255	119	223	255	251	250	245	229	232
    239	227	244	251	251	248	244	255	110	217	255	250	251	246	233	233
    233	237	250	252	249	242	246	255	115	209	255	250	251	246	232	232
    234	245	249	247	242	242	246	231	154	192	246	249	249	245	234	233
    ]/255;

% Export Figures Dialog
idx = idx + 1;
icons(idx).data(:,:,1) = ...
    [NaN	NaN	10	23	23	23	23	23	23	23	21	3	NaN	NaN	NaN	NaN
    NaN	NaN	67	255	255	255	255	255	255	255	201	141	NaN	NaN	NaN	NaN
    NaN	NaN	43	255	241	240	241	246	252	255	186	220	151	NaN	NaN	NaN
    NaN	NaN	42	255	238	237	237	236	238	254	210	178	214	38	NaN	NaN
    NaN	NaN	43	255	241	241	241	241	240	244	252	255	255	79	NaN	NaN
    NaN	NaN	47	255	232	232	225	224	224	223	220	238	255	69	NaN	NaN
    NaN	NaN	55	233	114	225	230	223	221	221	215	237	255	67	NaN	NaN
    4	NaN	37	181	168	126	193	214	205	200	203	242	255	67	NaN	NaN
    41	164	134	153	144	139	131	209	238	223	242	240	255	67	NaN	NaN
    41	118	91	91	122	125	120	106	170	241	245	241	255	67	NaN	NaN
    41	113	91	89	97	108	99	89	117	205	190	230	255	67	NaN	NaN
    41	124	94	88	78	74	81	179	255	252	244	241	255	67	NaN	NaN
    13	34	76	187	88	92	222	255	255	250	250	250	255	73	NaN	NaN
    NaN	NaN	69	236	121	227	255	243	238	238	238	238	255	82	NaN	NaN
    NaN	NaN	NaN	0	0	0	0	0	0	0	0	0	0	0	NaN	NaN]/255;


icons(idx).data(:,:,2) = ...
    [NaN	NaN	10	24	24	24	24	24	24	24	22	4	NaN	NaN	NaN	NaN
    NaN	NaN	69	255	255	255	255	255	255	255	204	144	NaN	NaN	NaN	NaN
    NaN	NaN	45	255	241	240	241	246	252	255	189	222	155	NaN	NaN	NaN
    NaN	NaN	43	255	238	237	237	236	238	254	210	179	215	39	NaN	NaN
    NaN	NaN	44	255	241	241	241	241	240	244	252	255	255	80	NaN	NaN
    NaN	NaN	49	255	231	230	225	224	224	223	220	238	255	70	NaN	NaN
    NaN	NaN	56	227	136	214	227	223	221	221	215	237	255	68	NaN	NaN
    4	NaN	19	157	243	154	181	210	204	200	203	242	255	67	NaN	NaN
    51	255	231	225	219	217	172	197	232	222	242	240	255	67	NaN	NaN
    52	227	184	183	195	201	204	172	169	239	245	241	255	67	NaN	NaN
    51	218	177	177	180	187	187	177	130	202	190	230	255	67	NaN	NaN
    51	237	195	183	172	170	152	175	255	251	244	241	255	67	NaN	NaN
    15	38	72	173	183	149	211	255	255	250	250	250	255	73	NaN	NaN
    NaN	NaN	65	226	174	214	252	242	238	238	238	238	255	84	NaN	NaN
    NaN	NaN	NaN	0	0	0	0	0	0	0	0	0	0	0	NaN	NaN]/255;


icons(idx).data(:,:,3) = ...
    [NaN	NaN	9	23	23	23	23	23	23	23	21	3	NaN	NaN	NaN	NaN
    NaN	NaN	66	255	255	255	255	255	255	255	196	139	NaN	NaN	NaN	NaN
    NaN	NaN	42	255	239	238	238	244	252	255	186	216	148	NaN	NaN	NaN
    NaN	NaN	41	255	236	235	235	234	237	251	210	176	212	36	NaN	NaN
    NaN	NaN	42	255	239	239	239	239	238	241	252	255	255	78	NaN	NaN
    NaN	NaN	46	255	233	232	224	223	223	223	219	235	255	67	NaN	NaN
    NaN	NaN	53	240	101	232	230	221	219	218	213	235	255	65	NaN	NaN
    5	NaN	60	212	94	107	205	215	203	198	201	240	255	66	NaN	NaN
    34	56	40	80	70	62	94	222	241	221	240	238	255	66	NaN	NaN
    35	10	2	0	51	55	36	46	176	240	243	239	255	66	NaN	NaN
    35	11	9	7	16	34	12	6	110	204	188	228	255	66	NaN	NaN
    35	14	0	0	0	0	14	187	255	251	242	239	255	66	NaN	NaN
    12	37	84	206	0	41	234	255	255	248	248	248	255	72	NaN	NaN
    NaN	NaN	69	249	79	239	255	240	236	236	236	236	255	80	NaN	NaN
    NaN	NaN	NaN	0	0	0	0	0	0	0	0	0	0	0	NaN	NaN]/255;


% [EOF] getIcons

function guiparams = createGUIparams
% Creates the guiparams structure with specified defaults.

% Organized by GUI panels
%%%%%%%%%%%%%%%%%%%
% SHIPTRACKS PLOT %
%%%%%%%%%%%%%%%%%%%
guiparams.horizontal_grid_node_spacing       = 1.0;

%%%%%%%%%%%%%%%%%%%%%%
% CROSS SECTION PLOT %
%%%%%%%%%%%%%%%%%%%%%%
guiparams.contours                           = ''; % Set below
guiparams.contour                            = ''; % Set below
guiparams.idx_contour                        = 1;
guiparams.vertical_exaggeration              = 10;
guiparams.vector_scale_cross_section         = 0.2;
guiparams.horizontal_vector_spacing          = 1;
guiparams.vertical_vector_spacing            = 1;
guiparams.horizontal_smoothing_window        = 1;
guiparams.vertical_smoothing_window          = 1;
guiparams.plot_secondary_flow_vectors        = true;
guiparams.secondary_flows                    = ''; % Set below
guiparams.secondary_flow_vector_variable     = ''; % Set below
guiparams.idx_secondary_flow_vector_variable = 1;
guiparams.include_vertical_velocity          = true;

%%%%%%%%%%%%%%%%%%
% PLAN VIEW PLOT %
%%%%%%%%%%%%%%%%%%
guiparams.depth_range_min                    = 0;
guiparams.depth_range_max                    = inf;
guiparams.vector_scale_plan_view             = 1;
guiparams.vector_spacing_plan_view           = 1;
guiparams.smoothing_window_size              = 1;
guiparams.map_depth_averaged_velocities      = true;
guiparams.display_shoreline                  = false;
guiparams.add_background                     = false;

%%%%%%%%%%%%%%%
% DATA EXPORT %
%%%%%%%%%%%%%%%
guiparams.beam_angle                         = 20.0;
guiparams.magnetic_variation                 = 0.0;
guiparams.wse                                = 0.0;
guiparams.output_auxiliary_data              = false;

%%%%%%%%%%%%%%%%%%%%%
% Contour variables %
%%%%%%%%%%%%%%%%%%%%%
idx = 1;
guiparams.contours(idx).string   = 'Streamwise Velocity (u)';
guiparams.contours(idx).variable = 'streamwise';
idx = idx + 1;
guiparams.contours(idx).string   = 'Transverse Velocity (v)';
guiparams.contours(idx).variable = 'transverse';
idx = idx + 1;
guiparams.contours(idx).string   = 'Vertical Velocity (w)';
guiparams.contours(idx).variable = 'vertical';
idx = idx + 1;
guiparams.contours(idx).string   = 'Velocity Magnitude';
guiparams.contours(idx).variable = 'mag';
idx = idx + 1;
guiparams.contours(idx).string   = 'Primary Velocity (zsd)';
guiparams.contours(idx).variable = 'primary_zsd';
idx = idx + 1;
guiparams.contours(idx).string   = 'Secondary Velocity (zsd)';
guiparams.contours(idx).variable = 'secondary_zsd';
idx = idx + 1;
guiparams.contours(idx).string   = 'Primary Velocity (Roz)';
guiparams.contours(idx).variable = 'primary_roz';
idx = idx + 1;
guiparams.contours(idx).string   = 'Secondary Velocity (Roz)';
guiparams.contours(idx).variable = 'secondary_roz';
idx = idx + 1;
guiparams.contours(idx).string   = 'Prim. Vel. (Roz, Downstream Comp.)';
guiparams.contours(idx).variable = 'primary_roz_x';
idx = idx + 1;
guiparams.contours(idx).string   = 'Prim. Vel. (Roz, Cross-Stream Comp.)';
guiparams.contours(idx).variable = 'primary_roz_y';
idx = idx + 1;
guiparams.contours(idx).string   = 'Sec. Vel. (Roz, Downstream Comp.)';
guiparams.contours(idx).variable = 'secondary_roz_x';
idx = idx + 1;
guiparams.contours(idx).string   = 'Sec. Vel. (Roz, Cross-Stream Comp.)';
guiparams.contours(idx).variable = 'secondary_roz_y';
idx = idx + 1;
guiparams.contours(idx).string   = 'Backscatter';
guiparams.contours(idx).variable = 'backscatter';
idx = idx + 1;
guiparams.contours(idx).string   = 'Flow Direction (deg.)';
guiparams.contours(idx).variable = 'flowangle';

guiparams.contour = guiparams.contours(guiparams.idx_contour).variable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Secondary Flow Vector Variables %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx = 1;
guiparams.secondary_flows(idx).string   = 'Transverse';
guiparams.secondary_flows(idx).variable = 'transverse';
idx = idx + 1;
guiparams.secondary_flows(idx).string   = 'Secondary (zsd)';
guiparams.secondary_flows(idx).variable = 'secondary_zsd';
idx = idx + 1;
guiparams.secondary_flows(idx).string   = 'Secondary (Roz)';
guiparams.secondary_flows(idx).variable = 'secondary_roz';
idx = idx + 1;
guiparams.secondary_flows(idx).string   = 'Secondary (Roz, Cross-Stream Comp)';
guiparams.secondary_flows(idx).variable = 'secondary_roz_y';
idx = idx + 1;
guiparams.secondary_flows(idx).string   = 'Primary (Roz, Cross-Stream Comp)';
guiparams.secondary_flows(idx).variable  = 'primary_roz_y';

guiparams.secondary_flow_vector_variable = ...
    guiparams.secondary_flows(guiparams.idx_secondary_flow_vector_variable).variable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL SETTINGS & DEFAULTS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu bar options
guiparams.presentation                       = true;
guiparams.print 							 = false;
guiparams.set_cross_section_endpoints        = false;
guiparams.unit_discharge_correction          = false;
guiparams.english_units                      = false;
guiparams.vertical_offset                    = 0;
% guiparams.plot_ship_tracks                   = false;
% guiparams.plot_planview                      = false;
% guiparams.plot_cross_section                 = false;

% File location defaults
guiparams.ascii_path                        = pwd;
guiparams.ascii_file                        = '';
guiparams.mat_path                          = pwd;
guiparams.mat_file                          = '';
guiparams.tecplot_path                      = pwd;
guiparams.tecplot_file                      = '';
guiparams.kmz_path                          = pwd;
guiparams.kmz_file                          = '';
guiparams.multibeambathymetry_path          = pwd;
guiparams.multibeambathymetry_file          = '';
guiparams.log_path                          = pwd;
guiparams.log_file                          = '';
% Avoids problems of not finding the MCR root when running as a standalone
% application
if isdeployed 
    guiparams.has_mapping_toolbox           = true;
else
    guiparams.has_mapping_toolbox               = ...
        ~isempty(dir(fullfile(matlabroot,'toolbox','map')));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% IN MEMORY DATA STORAGE %
%%%%%%%%%%%%%%%%%%%%%%%%%%
guiparams.z                      = [];
guiparams.A                      = [];
guiparams.V                      = [];
guiparams.Map                    = [];
guiparams.savefile               = [];
guiparams.iric_anv_planview_data = [];
% guiparams.zmin = []; % Don't need to store these?
% guiparams.zmax = [];
% guiprefs = getappdata(handles.figure1,'guiprefs');
guiparams.data_folder = '';
guiparams.data_files  = {''};

% [EOF] createGUIparams

% [EOF] VMT







