function varargout = VMT(varargin)
% VMT M-file for VMT.fig
%      VMT, by itself, creates a new VMT or raises the existing
%      singleton*.
%
%      H = VMT returns the handle to a new VMT or the handle to
%      the existing singleton*.
%
%      VMT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VMT.M with the given input arguments.
%
%      VMT('Property','Value',...) creates a new VMT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VMT_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VMT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VMT

% Last Modified by GUIDE v2.5 15-Oct-2012 08:40:20

%__________________________________________________________________________
% VMT version 2.42 beta 

% P.R. Jackson, U.S. Geological Survey, Illinois Water Science Center
% (pjackson@usgs.gov)

% Code contributed by D. Parsons, D. Mueller, J. Czuba, and F. Engel.  

%Although this program has been used by the U.S. Geological Survey (USGS),
%no warranty, expressed or implied, is made by the USGS or the U.S. 
%Government as to the accuracy and functioning of the program and related 
%program material nor shall the fact of distribution constitute any such 
%warranty, and no responsibility is assumed by the USGS in connection 
%therewith.
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



% --- Executes just before VMT is made visible.
function VMT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMT (see VARARGIN)

% Choose default command line output for VMT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VMT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VMT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%Initialize variables
handles.readasciiout    = 0;
handles.readmat         = 0;
handles.shoreline       = 0;
handles.planview        = 1;
handles.contour         = 1;
handles.savemat         = 0;
handles.secvec          = 1;
handles.var             = 'streamwise';
handles.qspacing        = 1;
handles.qscalecont      = 0.2;
handles.qspacingconth   = 1;
handles.qspacingcontv   = 1;
handles.qscale          = 1;
handles.vertexag        = 10;
handles.zerosecq        = 1;
handles.kmz             = 0;
handles.gevertoffset    = 0;
handles.hgns            = 1.0;
handles.ExpFig1         = 0.0;
handles.ExpFig2         = 0.0;
handles.ExpFig3         = 0.0;
handles.mbbathy         = 0;
handles.beamang         = 20.0;
handles.magvar          = 0.0;
handles.wse.elev        = 0.0;
handles.setends         = 0;
handles.secvecvar       = 'transverse';
handles.vvelcomp        = 1;
handles.horzsmwind      = 1;
handles.vertsmwind      = 1;
handles.tecplotout      = 0;
handles.pvsmwin         = 1;
handles.bathyauxout     = 0;
handles.figstyle        = 0;
handles.plot_english    = 0;
handles.unitQcorrection = 0;
guidata(hObject,handles)
warning off


%% --- Executes on button press in ASCIIRadio.
function ASCIIRadio_Callback(hObject, eventdata, handles)
% hObject    handle to ASCIIRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ASCIIRadio

handles.readasciiout = get(hObject,'Value');
handles.asciiread = hObject;  %handle to ASCIIRadio
if isfield(handles, 'matread')
    set(handles.matread,'Value',0);
    handles.readmat = 0;
end
guidata(hObject,handles)

%% --- Executes on button press in MatFiles.
function MatFiles_Callback(hObject, eventdata, handles)
% hObject    handle to MatFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MatFiles

handles.readmat = get(hObject,'Value'); 
handles.matread = hObject;  %handle to MatFilesRadio
if isfield(handles, 'asciiread')
    set(handles.asciiread,'Value',0);
    handles.readasciiout = 0;
end
guidata(hObject,handles)


%% --- Executes on button press in SaveDataCheckBox.
function SaveDataCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveDataCheckBox

handles.savemat = get(hObject,'Value'); 
guidata(hObject,handles)


%% --- Executes on button press in LoadDataButton.
function LoadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if handles.readasciiout    % Read Files into Data Structure using tfile
        
        %Check the GUI inputs
%         if ~isint(handles.qspacing) | handles.qspacing < 1
%             error('VMT:PlanView:VectorSpacing. Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
%         end
%         if ~isint(handles.qspacingconth) | handles.qspacingconth < 1
%             error('VMT:CrossSections:HorizontalVectorSpacing. Horizontal Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
%         end
%         if ~isint(handles.qspacingcontv) | handles.qspacingcontv < 1
%             error('VMT:CrossSections:VerticalVectorSpacing. Vertical Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
%         end
%         if handles.readasciiout & handles.readmat
%             error('VMT:ReadData.  Both ASCII and MAT read options chosen.  Select only one option.')
%         end
               
        [zPathName,zFileName,savefile,A,z] = VMT_ReadFiles;
        handles.savefile = savefile;
        handles.zPathName = zPathName;

        % Plot a Shoreline Map
        if handles.shoreline 
            Map = VMT_LoadMap('txt','UTM');
            figure(1); clf
            VMT_PlotShoreline(Map)
        else
            Map = [];
        end

        % Preprocess the data
        A = VMT_PreProcess(z,A);
        
        if handles.kmz & handles.shoreline
            VMT_Shoreline2GE_3D(A,Map,handles.vertexag,handles.gevertoffset);
        end
        
        %Compute multibeam bathymetry
        if handles.mbbathy
            msgbox('Processing Bathymetry...Please Be Patient','VMT Status','help','replace');
            %A = VMT_MBBathy(z,A,savefile,handles.beamang,handles.magvar,handles.wse);
            A = VMT_MBBathyV3(z,A,savefile,handles.beamang,handles.magvar,handles.wse,handles.bathyauxout);
            msgbox('Bathymetry Output Complete','VMT Status','help','replace');
            return
        end

        % Process the transects
        hmsg = msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');
        A(1).hgns = handles.hgns;
        A(1).wse  = handles.wse.elev;  %Set the WSE to entered value
        [A,V] = VMT_ProcessTransectsV3(z,A,handles.setends,handles.unitQcorrection);
        msgbox('Processing Complete','VMT Status','help','replace');
        
        % Smooth
        %[A,V] = VMT_SmoothV3(A,V,handles.horzsmwind,handles.vertsmwind);

        % Save the processed data
        if handles.savemat
            disp('Saving Processed Data File...')
            disp(savefile)
            save(savefile, 'A','V','z','Map');
            handles.savefile = savefile;
        end
        
        %Output the data (no smoothing) to Tecplot
        
        if handles.tecplotout
            msgbox('Exporting Data to Tecplot (*.dat) File...','VMT Status','help','replace');
            VMT_BuildTecplotFileV2(V,savefile);
            msgbox('Tecplot Export Complete','VMT Status','help','replace');
            msgbox('Exporting XS Bathy Data to Tecplot (*.dat) File...','VMT Status','help','replace');
            VMT_BuildTecplotFile_XSBathy(V,savefile);
            msgbox('Tecplot Export Complete','VMT Status','help','replace');
        end

        % Plot the data
        if handles.planview
            msgbox('Plotting Plan View','VMT Status','help','replace');
            if isfield(handles,'depthmin') 
                handles.dpthrng = [handles.depthmin handles.depthmax];
            else
                handles.dpthrng = []; %full range of depths
            end
            handles.PVdata = VMT_PlotPlanViewQuiversASCv4(z,A,V,Map,handles.dpthrng,handles.qscale,handles.qspacing,handles.pvsmwin,handles.shoreline,handles.plot_english);            
        end

        if handles.contour & handles.secvec
            msgbox('Plotting Cross Section','VMT Status','help','replace');
            [V] = VMT_SmoothVar(V,handles.var,handles.horzsmwind,handles.vertsmwind);
            [V] = VMT_SmoothVar(V,handles.secvecvar,handles.horzsmwind,handles.vertsmwind);
            [z,A,V] = VMT_PlotXSContQuiverV5(z,A,V,handles.var,handles.qscalecont,handles.vertexag,handles.qspacingconth,handles.qspacingcontv,handles.secvecvar,handles.vvelcomp,handles.plot_english);
            if handles.kmz
                VMT_MeanXS2GE_3D(A,V,[],savefile,handles.vertexag,handles.gevertoffset);
            end
        elseif handles.contour &  ~handles.secvec
            msgbox('Plotting Cross Section','VMT Status','help','replace');
            [V] = VMT_SmoothVar(V,handles.var,handles.horzsmwind,handles.vertsmwind);
            [z,A,V,zmin,zmax] = VMT_PlotXSContV3(z,A,V,handles.var,handles.vertexag,handles.plot_english);
            if handles.kmz
                VMT_MeanXS2GE_3D(A,V,[],savefile,handles.vertexag,handles.gevertoffset);
            end
            handles.zmin = zmin;
            handles.zmax = zmax;
        end

        handles.z = z;
        handles.A = A;
        handles.V = V;
        if handles.shoreline
            handles.Map = Map;
        else
            handles.Map = [];
        end
        
        %Output a text file
        if 0
            xyzdata = VMT_BuildXYZOutput(V);
            dlmwrite([savefile(1:end-4) '_xyz.csv'],xyzdata,'precision',10);
        end
      
       
    end

    if handles.readmat    % Read Files into Data Structure using tfile

        [zPathName,zFileName,zf] = VMT_SelectFiles;  %Have the user select the preprocessed input files

        handles.zPathName = zPathName;
        handles.zFileName = zFileName;
        handles.zf        = zf;

        % Plot the data
        if handles.planview
            if isfield(handles,'depthmin') 
                handles.dpthrng = [handles.depthmin handles.depthmax];
            else
                handles.dpthrng = []; %full range of depths
            end
            msgbox('Plotting Plan View','VMT Status','help','replace');
            handles.PVdata = VMT_PlotPlanViewQuiversMATv4(handles.zPathName,handles.zFileName,handles.zf,handles.dpthrng,handles.qscale,handles.qspacing,handles.pvsmwin,handles.shoreline,handles.plot_english); 
        end

        if handles.contour
            eval(['load ' zPathName '\' zFileName{1}]);
            % Smooth
            %[A,V] = VMT_SmoothV3(A,V,handles.qspacingconth,handles.qspacingcontv);
        end

        if handles.contour & handles.secvec 
            msgbox('Plotting Cross Section','VMT Status','help','replace');
            [V] = VMT_SmoothVar(V,handles.var,handles.horzsmwind,handles.vertsmwind);
            [V] = VMT_SmoothVar(V,handles.secvecvar,handles.horzsmwind,handles.vertsmwind);
            [z,A,V] = VMT_PlotXSContQuiverV5(z,A,V,handles.var,handles.qscalecont,handles.vertexag,handles.qspacingconth,handles.qspacingcontv,handles.secvecvar,handles.vvelcomp,handles.plot_english);
            if handles.kmz
                VMT_MeanXS2GE_3D(A,V,zPathName,zFileName{1},handles.vertexag,handles.gevertoffset);
            end
        elseif handles.contour & ~handles.secvec
            msgbox('Plotting Cross Section','VMT Status','help','replace');
            [V] = VMT_SmoothVar(V,handles.var,handles.horzsmwind,handles.vertsmwind);
            [z,A,V,zmin,zmax] = VMT_PlotXSContV3(z,A,V,handles.var,handles.vertexag,handles.plot_english);
            if handles.kmz
                VMT_MeanXS2GE_3D(A,V,zPathName,zFileName{1},handles.vertexag,handles.gevertoffset);
            end
            handles.zmin = zmin;
            handles.zmax = zmax;
        end

        if handles.contour
            handles.z = z;
            handles.A = A;
            handles.V = V;
        end

    end

msgbox('Plotting Complete','VMT Status','help','replace');
guidata(hObject,handles)

%% --- Executes on button press in ShorelineCheckbox.
function ShorelineCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShorelineCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShorelineCheckbox

handles.shoreline = get(hObject,'Value');
guidata(hObject,handles)

return

%% --- Executes on button press in MDAVCheckBox.
function MDAVCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to MDAVCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MDAVCheckBox

handles.planview = get(hObject,'Value');
guidata(hObject,handles)


%%
function DepthMin_Callback(hObject, eventdata, handles)
% hObject    handle to DepthMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthMin as text
%        str2double(get(hObject,'String')) returns contents of DepthMin as a double

handles.depthmin = str2double(get(hObject,'String')) ;
if handles.depthmin < 0
    errordlg('Min Depth Must Be Greater Than or Equal to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function DepthMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function DepthMax_Callback(hObject, eventdata, handles)
% hObject    handle to DepthMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthMax as text
%        str2double(get(hObject,'String')) returns contents of DepthMax as a double

handles.depthmax = str2double(get(hObject,'String')) ;
if handles.depthmax < 0
    errordlg('Max Depth Must Be Greater Than or Equal to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function DepthMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in ContourCheckBox.
function ContourCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ContourCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ContourCheckBox

handles.contour = get(hObject,'Value');
guidata(hObject,handles)


%% --- Executes on selection change in Var.
function Var_Callback(hObject, eventdata, handles)
% hObject    handle to Var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Var contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Var

str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
    case 'Streamwise Velocity (u)' % 
        var = 'streamwise';
    case 'Transverse Velocity (v)' % 
        var = 'transverse';
    case 'Vertical Velocity (w)' % 
        var = 'vertical';
    case 'Velocity Magnitude' % 
        var = 'mag';
    case 'Primary Velocity (zsd)'
        var = 'primary_zsd';
    case 'Secondary Velocity (zsd)'
        var = 'secondary_zsd';
    case 'Primary Velocity (Roz)'
        var = 'primary_roz';
    case 'Secondary Velocity (Roz)'
        var = 'secondary_roz';
    case 'Prim. Vel. (Roz, Downstream Comp.)'
        var = 'primary_roz_x';
    case 'Prim. Vel. (Roz, Cross-Stream Comp.)'
        var = 'primary_roz_y';
    case 'Sec. Vel. (Roz, Downstream Comp.)'
        var = 'secondary_roz_x';
    case 'Sec. Vel. (Roz, Cross-Stream Comp.)'
        var = 'secondary_roz_y';
    case 'Backscatter' % 
        var = 'backscatter';
    case 'Flow Direction (deg.)' % 
        var = 'flowangle';
%     case 'Directional Deviation' % 
%         var = 'dirdevp';
end

handles.var = var;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function Var_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in SecVecCheckbox.
function SecVecCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to SecVecCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SecVecCheckbox

handles.secvec = get(hObject,'Value');
guidata(hObject,handles)

%% --- Executes on button press in ReplotPushButton.
function ReplotPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReplotPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.readasciiout    % Read Files into Data Structure using tfile
    
    %[handles.A,handles.V] = VMT_SmoothV3(handles.A,handles.V,handles.qspacingconth,handles.qspacingcontv);
    
    % Plot the data
    if handles.planview
        msgbox('Replotting Plan View...','VMT Status','help','replace');
        if isfield(handles,'depthmin') 
            handles.dpthrng = [handles.depthmin handles.depthmax];
        else
            handles.dpthrng = []; %full range of depths
        end
        handles.PVdata = VMT_PlotPlanViewQuiversASCv4(handles.z,handles.A,handles.V,handles.Map,handles.dpthrng,handles.qscale,handles.qspacing,handles.pvsmwin,handles.shoreline,handles.plot_english);
    end

    if handles.contour & handles.secvec
        msgbox('Replotting Cross Section...','VMT Status','help','replace');
        [handles.V] = VMT_SmoothVar(handles.V,handles.var,handles.horzsmwind,handles.vertsmwind);
        [handles.V] = VMT_SmoothVar(handles.V,handles.secvecvar,handles.horzsmwind,handles.vertsmwind);
        VMT_PlotXSContQuiverV5(handles.z,handles.A,handles.V,handles.var,handles.qscalecont,handles.vertexag,handles.qspacingconth,handles.qspacingcontv,handles.secvecvar,handles.vvelcomp,handles.plot_english);%[handles.z,handles.A,handles.V] = 
        if handles.kmz
            VMT_MeanXS2GE_3D(handles.A,handles.V,[],handles.savefile,handles.vertexag,handles.gevertoffset);
        end
    elseif handles.contour & ~handles.secvec
        msgbox('Replotting Cross Section...','VMT Status','help','replace');
        [handles.V] = VMT_SmoothVar(handles.V,handles.var,handles.horzsmwind,handles.vertsmwind);
        [handles.z,handles.A,handles.V,zmin,zmax] = VMT_PlotXSContV3(handles.z,handles.A,handles.V,handles.var,handles.vertexag,handles.plot_english);
        if handles.kmz
            VMT_MeanXS2GE_3D(handles.A,handles.V,[],handles.savefile,handles.vertexag,handles.gevertoffset);
        end
        handles.zmin = zmin;
        handles.zmax = zmax;
    end

end

if handles.readmat    % Load mat files
    
    if handles.contour
        %[handles.A,handles.V] = VMT_SmoothV3(handles.A,handles.V,handles.qspacingconth,handles.qspacingcontv);
    end
    
    % Plot the data
    if handles.planview
        msgbox('Replotting Plan View...','VMT Status','help','replace');
        if isfield(handles,'depthmin') 
            handles.dpthrng = [handles.depthmin handles.depthmax];
        else
            handles.dpthrng = []; %full range of depths
        end
        handles.PVdata = VMT_PlotPlanViewQuiversMATv4(handles.zPathName,handles.zFileName,handles.zf,handles.dpthrng,handles.qscale,handles.qspacing,handles.pvsmwin,handles.shoreline,handles.plot_english); 
    end

    if handles.contour & handles.secvec 
        msgbox('Replotting Cross Section...','VMT Status','help','replace');
        [handles.V] = VMT_SmoothVar(handles.V,handles.var,handles.horzsmwind,handles.vertsmwind);
        [handles.V] = VMT_SmoothVar(handles.V,handles.secvecvar,handles.horzsmwind,handles.vertsmwind);
        VMT_PlotXSContQuiverV5(handles.z,handles.A,handles.V,handles.var,handles.qscalecont,handles.vertexag,handles.qspacingconth,handles.qspacingcontv,handles.secvecvar,handles.vvelcomp,handles.plot_english);%[handles.z,handles.A,handles.V] = 
        if handles.kmz
            VMT_MeanXS2GE_3D(handles.A,handles.V,handles.zPathName,handles.zFileName{1},handles.vertexag,handles.gevertoffset);
        end
    elseif handles.contour & ~handles.secvec
        msgbox('Replotting Cross Section...','VMT Status','help','replace');
        [handles.V] = VMT_SmoothVar(handles.V,handles.var,handles.horzsmwind,handles.vertsmwind);
        [handles.z,handles.A,handles.V,handles.zmin,handles.zmax] = VMT_PlotXSContV3(handles.z,handles.A,handles.V,handles.var,handles.vertexag,handles.plot_english);
        if handles.kmz
            VMT_MeanXS2GE_3D(handles.A,handles.V,handles.zPathName,handles.zFileName{1},handles.vertexag,handles.gevertoffset);
        end
        %handles.zmin = zmin;
        %handles.zmax = zmax;
    end
    
end

msgbox('Replotting Complete','VMT Status','help','replace');
guidata(hObject,handles)

%% Set quiver scale (plan view)

function QuivScale_Callback(hObject, eventdata, handles)
% hObject    handle to QuivScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QuivScale as text
%        str2double(get(hObject,'String')) returns contents of QuivScale as a double

handles.qscale = str2double(get(hObject,'String'));
if handles.qscale <= 0
    errordlg('Plan View Vector Scale Must Be Greater Than Zero')
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function QuivScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuivScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Set quiver spacing (Plan view)

function QuivSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to QuivSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QuivSpacing as text
%        str2double(get(hObject,'String')) returns contents of QuivSpacing as a double

handles.qspacing = str2double(get(hObject,'String'));
if ~isint(handles.qspacing)||handles.qspacing <= 0
    errordlg('Vector Spacing Must Be a Positive Integer')
end
% if ~isint(handles.qspacing) | handles.qspacing < 1
%     %handles.qspacing = 1;
%     error('VMT:Plan View:Vector Spacing. Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
% end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function QuivSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuivSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% Set quiver scale (contour)

function qscale_cont_Callback(hObject, eventdata, handles)
% hObject    handle to qscale_cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qscale_cont as text
%        str2double(get(hObject,'String')) returns contents of qscale_cont as a double

handles.qscalecont = str2double(get(hObject,'String'));
if handles.qscalecont <= 0
    errordlg('Contour Vector Scale Must Be Greater Than Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function qscale_cont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qscale_cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Set quiver spacing (contour, horizontal)

function Qspacing_cont_Callback(hObject, eventdata, handles)
% hObject    handle to Qspacing_cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Qspacing_cont as text
%        str2double(get(hObject,'String')) returns contents of Qspacing_cont as a double

handles.qspacingconth = str2double(get(hObject,'String'));
if ~isint(handles.qspacingconth)||handles.qspacingconth <= 0
    errordlg('Horizontal Vector Spacing Must Be a Positive Integer')
end
% if ~isint(handles.qspacingconth) | handles.qspacingconth < 1
%     error('VMT:CrossSections:Horizontal Vector Spacing. Horizontal Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
% end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function Qspacing_cont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Qspacing_cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Set vertical exaggeration 

function VertExag_Callback(hObject, eventdata, handles)
% hObject    handle to VertExag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VertExag as text
%        str2double(get(hObject,'String')) returns contents of VertExag as a double

handles.vertexag = str2double(get(hObject,'String'));
if handles.vertexag < 0
    errordlg('Vertical Exaggeration Must Be Greater Than or Equal to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function VertExag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VertExag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%% --- Executes on button press in zerosecq_chkbox.
%function zerosecq_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to zerosecq_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zerosecq_chkbox

%handles.zerosecq = get(hObject,'Value');
%guidata(hObject,handles)




%% --- Executes on button press in KMZcheckbox.
function KMZcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to KMZcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KMZcheckbox

handles.kmz = get(hObject,'Value');
if handles.kmz == 1;
    set(handles.vertoff,'Enable','on')
else
    set(handles.vertoff,'Enable','off')
end
guidata(hObject,handles)



%% Set the vertical offset for google earth export
function gevertoffset_Callback(hObject, eventdata, handles)
% hObject    handle to gevertoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gevertoffset as text
%        str2double(get(hObject,'String')) returns contents of gevertoffset as a double

handles.gevertoffset = str2double(get(hObject,'String'));    
if handles.gevertoffset < 0
    errordlg('Google Earth Vertical Offset Must Be Greater Than or Equal to Zero')
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function gevertoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gevertoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.vertoff = hObject; %handle to vertical offset box
guidata(hObject,handles)



%% Set the horizontal grid node spacing
function HGNspacingVal_Callback(hObject, eventdata, handles)
% hObject    handle to HGNspacingVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HGNspacingVal as text
%        str2double(get(hObject,'String')) returns contents of HGNspacingVal as a double

handles.hgns = str2double(get(hObject,'String'));
if handles.hgns <= 0
    errordlg('Horizontal Grid Node Spacing Must Be Greater Than Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function HGNspacingVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HGNspacingVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%% --- Executes on button press in SaveFigsPushButton.
function SaveFigsPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFigsPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fignums = [];
if handles.ExpFig1
    fignums = [fignums 1];
end
if handles.ExpFig2
    fignums = [fignums 2];
end
if handles.ExpFig3
    fignums = [fignums 3];
end

%Get the save path
if handles.readasciiout %& handles.savemat
    figpath = handles.savefile(1:end-4);
elseif handles.readmat
    figpath = [handles.zPathName '\' handles.zFileName{1}(1:end-4)];
else
    disp('No Path Specified to Save Figures--Select "Save .mat Files Box"')
end

VMT_SaveFigs(figpath,fignums,handles.figstyle)


%% --- Executes on button press in ExportFig1checkbox.
function ExportFig1checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ExportFig1checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportFig1checkbox
handles.ExpFig1 = get(hObject,'Value');
guidata(hObject,handles)

%% --- Executes on button press in ExportFig2CheckBox.
function ExportFig2CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ExportFig2CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportFig2CheckBox
handles.ExpFig2 = get(hObject,'Value');
guidata(hObject,handles)

%% --- Executes on button press in ExportFig3CheckBox.
function ExportFig3CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ExportFig3CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportFig3CheckBox
handles.ExpFig3 = get(hObject,'Value');
guidata(hObject,handles)



%% --- Executes on button press in mbbout_checkbox.
function mbbout_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to mbbout_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mbbout_checkbox

handles.mbbathy = get(hObject,'Value');
guidata(hObject,handles)

%% Get the beam angle
function beamang_Callback(hObject, eventdata, handles)
% hObject    handle to beamang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beamang as text
%        str2double(get(hObject,'String')) returns contents of beamang as a double

handles.beamang = str2double(get(hObject,'String'));
if handles.beamang < 0
    errordlg('Beam Angle Must Be Greater Than or Equal to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function beamang_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Get the magvar
function magvar_Callback(hObject, eventdata, handles)
% hObject    handle to magvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magvar as text
%        str2double(get(hObject,'String')) returns contents of magvar as a double

handles.magvar = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function magvar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Get the water surface elevation 
function wse_Callback(hObject, eventdata, handles)
% hObject    handle to wse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wse as text
%        str2double(get(hObject,'String')) returns contents of wse as a double

wseval = str2double(get(hObject,'String'));
if isnan(wseval)
    clear handles.wse
   [wsefile,wsepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select WSE CSV Text File','C:\');
   infile = [wsepath wsefile];
   wsedata = dlmread(infile,',');
   %Parse the data
   handles.wse.elev = wsedata(:,7); %WSE assumed in meters
   wseyear = wsedata(:,1); 
   wsemon  = wsedata(:,2); 
   wseday  = wsedata(:,3); 
   wsehr   = wsedata(:,4); 
   wsemin  = wsedata(:,5); 
   wsesec  = wsedata(:,6);
   handles.wse.obstime = datenum([wseyear wsemon wseday wsehr wsemin wsesec]); %WSE observation time as a datenumber
   msgbox('WSE file successfully loaded','VMT Status','help','replace');
else
   clear handles.wse
   handles.wse.elev = wseval; 
   A(1).wse = handles.wse.elev;
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function wse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Get the vertical quiver spacing for contour plots 
function qspacingcontv_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to qspacingcontv_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qspacingcontv_editbox as text
%        str2double(get(hObject,'String')) returns contents of qspacingcontv_editbox as a double

handles.qspacingcontv = str2double(get(hObject,'String'));
if ~isint(handles.qspacingcontv)||handles.qspacingcontv <= 0
    errordlg('Vertical Vector Spacing Must Be a Positive Integer')
end
% if ~isint(handles.qspacingcontv) | handles.qspacingcontv < 1
%     error('VMT:CrossSections:Vertical Vector Spacing. Vertical Vector Spacing not an integer or less than unity.  Set to Integer >= 1.')
% end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function qspacingcontv_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qspacingcontv_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Set the cross section endpoints manually

% --- Executes on button press in setends_checkbox.
function setends_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to setends_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setends_checkbox

handles.setends = get(hObject,'Value');
guidata(hObject,handles)



%% --- Executes on selection change in SecVecVar.
function SecVecVar_Callback(hObject, eventdata, handles)
% hObject    handle to SecVecVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SecVecVar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SecVecVar

str = get(hObject, 'String');
secvecvar = get(hObject,'Value');
% Set current data to the selected data set.
switch str{secvecvar};
    case 'Transverse' % 
        secvecvar = 'transverse';
    case 'Secondary (zsd)' % 
        secvecvar = 'secondary_zsd';
    case 'Secondary (Roz)' % 
        secvecvar = 'secondary_roz';
    case 'Secondary (Roz, Cross-Stream Comp)' % 
        secvecvar = 'secondary_roz_y';        
    case 'Primary (Roz, Cross-Stream Comp)' % 
        secvecvar = 'primary_roz_y';
end

handles.secvecvar = secvecvar;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function SecVecVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SecVecVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in vertvelcomp.
function vertvelcomp_Callback(hObject, eventdata, handles)
% hObject    handle to vertvelcomp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vertvelcomp

handles.vvelcomp = get(hObject,'Value');
guidata(hObject,handles)


%% Horizontal Smoothing 
function horzSmWind_Callback(hObject, eventdata, handles)
% hObject    handle to horzSmWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of horzSmWind as text
%        str2double(get(hObject,'String')) returns contents of horzSmWind as a double

handles.horzsmwind = str2double(get(hObject,'String'));
if ~isint(handles.horzsmwind)||handles.horzsmwind < 0
    errordlg('Horizontal Smoothing Window Size Must Be a Positive Integer or Zero')
end
if handles.horzsmwind == 0
    warndlg('Must Also Set Vertical Smoothing Window to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function horzSmWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to horzSmWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Vertical Smoothing
function vertSmWind_Callback(hObject, eventdata, handles)
% hObject    handle to vertSmWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vertSmWind as text
%        str2double(get(hObject,'String')) returns contents of vertSmWind as a double

handles.vertsmwind = str2double(get(hObject,'String'));
if ~isint(handles.vertsmwind)||handles.vertsmwind < 0
    errordlg('Vertical Smoothing Window Size Must Be a Positive Integer or Zero')
end
if handles.vertsmwind == 0
    warndlg('Must Also Set Horizontal Smoothing Window to Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function vertSmWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vertSmWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in tecplotout.
function tecplotout_Callback(hObject, eventdata, handles)
% hObject    handle to tecplotout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tecplotout

handles.tecplotout = get(hObject,'Value');
guidata(hObject,handles)


%% Plan View smoothing window size
function pvsmwin_Callback(hObject, eventdata, handles)
% hObject    handle to pvsmwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pvsmwin as text
%        str2double(get(hObject,'String')) returns contents of pvsmwin as a double

handles.pvsmwin = str2double(get(hObject,'String'));
if ~isint(handles.pvsmwin)||handles.pvsmwin < 0
    errordlg('Plan View Smoothing Window Size Must Be a Positive Integer or Zero')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pvsmwin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pvsmwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Bathymetry Auxillary Data

% --- Executes on button press in OutAuxDataCheckbox.
function OutAuxDataCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to OutAuxDataCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OutAuxDataCheckbox

handles.bathyauxout = get(hObject,'Value');
guidata(hObject,handles)

%% DOQQ aerial photo overlay

% --- Executes on button press in DOQQButton.
function DOQQButton_Callback(hObject, eventdata, handles)
% hObject    handle to DOQQButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Adding Background','VMT Status','help','replace');
VMT_OverlayDOQQ
msgbox('Replotting Complete','VMT Status','help','replace');


%% Save graphics type 
% --- Executes when selected object is changed in uipanel13.
function uipanel13_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel13 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'PresentationRadio'
        handles.figstyle = 0;
    case 'PrintRadio'
        handles.figstyle = 1;
    % Continue with more cases as necessary.
    otherwise
        handles.figstyle = 0;
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function uipanel10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object deletion, before destroying properties.
function uipanel10_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Compute the longitudinal dispersion coefficient
% --- Executes on button press in DispCoef_PushButton.
function DispCoef_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to DispCoef_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 msgbox('Advanced processing features are currently under development.  Please check back with future versions.','VMT Status','help','replace');

% msgbox('Computing Longitudinal Dispersion Coefficient','VMT Status','help','replace');
% [k,kc,Ey,dcQ] = VMT_ComputeDispCoef(handles.z,handles.A,handles.V);
% msgbox({'Computation Complete',['K (m^2/s) = ' num2str(k) ' Variable Ey'],['K (m^2/s) = ' num2str(kc) ' Constant Ey']},'VMT Status','help','replace');


% --- Executes on button press in EnglishUnitCheckBox.
function EnglishUnitCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to EnglishUnitCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnglishUnitCheckBox

handles.plot_english = get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('\VMT\VMTUserGuide.pdf') == 2
    open('\VMT\VMTUserGuide.pdf')
else
    web('http://hydroacoustics.usgs.gov/movingboat/VMT/Documentation/VMTUserGuide_Ver2.3.pdf','-browser') 
    %errordlg('No VMT User Manual (VMTUserManual.pdf) Present in VMT Code Directory')
end


%% Export the Plan View vector data
% --- Executes on button press in ExportPVdata.
function ExportPVdata_Callback(hObject, eventdata, handles)
% hObject    handle to ExportPVdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for output data
if isfield(handles, 'PVdata')
    % Save the planview data as output and to an *.anv file with spacing and smoothing (for iRiC) 
    disp('Exporting ANV vector file...')
    [file,path] = uiputfile('*.anv','Save *.anv file',handles.zPathName);
    outfile = [path file];
    disp(outfile)
    ofid   = fopen(outfile, 'wt');
    outcount = fprintf(ofid,'%8.2f  %8.2f  %5.2f  %3.3f  %3.3f\n',handles.PVdata.outmat);
    fclose(ofid);
    
    if 0  % Generate GE vector file  (Added 8-28-12. PRJ Still debugging)
        [dumx,dumy,utmzone] = deg2utm(handles.A(1).Nav.lat_deg(1),handles.A(1).Nav.long_deg(1)); 
        utmzoneMAT = repmat(utmzone,length(handles.PVdata.outmat(1,:)),1);
        [kmlLat,kmlLon] = utm2deg(handles.PVdata.outmat(1,:),handles.PVdata.outmat(2,:),utmzoneMAT);
        kmlVeast  = handles.PVdata.outmat(4,:)';
        kmlVnorth = handles.PVdata.outmat(5,:)'; 
        kmlVecFile = [outfile(1:end-4) '_VEC.kml']
        [kmlVectorFile] = vel2kml(kmlLon,kmlLat,kmlVeast,kmlVnorth,kmlVecFile);

        %Write the data to a file (PRJ, 8-28-12)
        % Scale Output
        % Calculate velocity magnitudes from all the velocities
        kmlvMag = sqrt(kmlVeast.^2 + kmlVnorth.^2);

        % Assign max and min velocity magnitudes for input to scale4kml
        kmlminV = min(kmlvMag);
        kmlmaxV = max(kmlvMag);

        % Assign max and min lon and lat for input to scale4kml
        kmlminLon = min(kmlLon);
        kmlmaxLon = max(kmlLon);
        kmlminLat = min(kmlLat);
        kmlmaxLat = max(kmlLat);

        % Call scale4kml to make scale parameters based on all the data
        [kmlScaleStr] = scale4kml(kmlminLon, kmlmaxLon, kmlminLat, kmlmaxLat, kmlminV, kmlmaxV);

        %Combine data and scaling 
        kmlStr_all = [ge_folder('Scale Parameters',kmlScaleStr), ge_folder('Velocity Vectors',kmlVectorFile)];

        % Generate output
        ge_output(kmlVecFile,mlStr_all);

    end
else
    errordlg('No Vector Data Present.  Please load a MAT file and retry.')
end


% --- Executes on button press in disclaimerButton.
function disclaimerButton_Callback(hObject, eventdata, handles)
% hObject    handle to disclaimerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

warndlg(['Although this program has been used by the U.S. Geological Survey (USGS), '...
    'no warranty, expressed or implied, is made by the USGS or the U.S. Government '...
    'as to the accuracy and functioning of the program and related program material '...
    'nor shall the fact of distribution constitute any such warranty, and no '...
    'responsibility is assumed by the USGS in connection therewith.'],'VMT Disclaimer')



% --- Executes on button press in unitQcorrection_checkbox.
function unitQcorrection_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to unitQcorrection_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of unitQcorrection_checkbox

handles.unitQcorrection = get(hObject,'Value');
guidata(hObject,handles)
