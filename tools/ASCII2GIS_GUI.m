function varargout = ASCII2GIS_GUI(varargin)
% ASCII2GIS_GUI M-file for ASCII2GIS_GUI.fig
%      ASCII2GIS_GUI, by itself, creates a new ASCII2GIS_GUI or raises the existing
%      singleton*.
%
%      H = ASCII2GIS_GUI returns the handle to a new ASCII2GIS_GUI or the handle to
%      the existing singleton*.
%
%      ASCII2GIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASCII2GIS_GUI.M with the given input arguments.
%
%      ASCII2GIS_GUI('Property','Value',...) creates a new ASCII2GIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASCII2GIS_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASCII2GIS_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASCII2GIS_GUI

% Last Modified by GUIDE v2.5 29-Apr-2014 13:04:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASCII2GIS_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ASCII2GIS_GUI_OutputFcn, ...
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


% --- Executes just before ASCII2GIS_GUI is made visible.
function ASCII2GIS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASCII2GIS_GUI (see VARARGIN)

% Choose default command line output for ASCII2GIS_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Ensure path to utils & docs is available
% ----------------------------------------
if ~isdeployed
    filesep = '\'; % windows
    utilspath = [pwd filesep 'utils'];
    docspath  = [pwd filesep 'doc'];
    toolspath = [pwd filesep 'tools'];
    addpath(utilspath,docspath,toolspath)
end

% UIWAIT makes ASCII2GIS_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ASCII2GIS_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%Initialize variables
handles.dfslow       = 0;
handles.dfshi        = 1;
handles.hablim       = 1;
handles.DFSfull      = 0;
handles.units        = 1;
handles.ref          = 1;
handles.VelOut       = [];
handles.goodrows     = [];
handles.Ascale       = 1.0;
handles.Vspace       = 1;
handles.TAV          = [];

guidata(hObject, handles);


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ref 
    vref = 'dfs';
    disp('Reference is set to DFS')
    if handles.DFSfull
        drange = [];
        disp('DFS Range set to Full Depth' )
    else
        if handles.units 
            drange = [handles.dfslow handles.dfshi];
            disp(['DFS Range = ' num2str(drange(1)) ' to ' num2str(drange(2)) ' m'])
        else %units = Feet
            drange = [handles.dfslow handles.dfshi]./3.281;  % Convert to meters
            disp(['DFS Range = ' num2str(drange(1)*3.281) ' to ' num2str(drange(2)*3.281) ' ft'])
        end
    end
else
    vref = 'hab';
    disp('Reference is set to HAB')
    if handles.units 
        drange = handles.hablim;
        disp(['HAB Limit = ' num2str(drange) ' m'])
    else %units = Feet
        drange = handles.hablim./3.281;  % Convert to meters
        disp(['HAB Limit = ' num2str(drange*3.281) ' ft'])
    end
end
 
[handles.VelOut,handles.goodrows] = ASCII2GIS(drange,vref,handles.TAV);
guidata(hObject,handles)

% --- Executes on button press in FullDepthcheckbox.
function FullDepthcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to FullDepthcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FullDepthcheckbox
handles.DFSfull = get(hObject,'Value');
guidata(hObject,handles)




function DFSlow_Callback(hObject, eventdata, handles)
% hObject    handle to DFSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DFSlow as text
%        str2double(get(hObject,'String')) returns contents of DFSlow as a double
handles.dfslow = str2double(get(hObject,'String'));
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function DFSlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DFSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DFShi_Callback(hObject, eventdata, handles)
% hObject    handle to DFShi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DFShi as text
%        str2double(get(hObject,'String')) returns contents of DFShi as a double
handles.dfshi = str2double(get(hObject,'String'));
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function DFShi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DFShi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HABlim_Callback(hObject, eventdata, handles)
% hObject    handle to HABlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HABlim as text
%        str2double(get(hObject,'String')) returns contents of HABlim as a double
handles.hablim = str2double(get(hObject,'String'));
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function HABlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HABlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'DFSradiobutton'
        handles.ref = 1;
    case 'HABradiobutton'
        handles.ref = 0;
    % Continue with more cases as necessary.
    otherwise
        handles.ref = 1;
end
guidata(hObject,handles)



% --- Executes when selected object is changed in uipanel3.
function uipanel3_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel3 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'Feetradiobutton'
        handles.units = 0;
    case 'Metersradiobutton'
        handles.units = 1;
    % Continue with more cases as necessary.
    otherwise
        handles.units = 1;
end
guidata(hObject,handles)


% --- Executes on button press in PlotDAVcheckbox.
function PlotDAVcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to PlotDAVcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotDAVcheckbox

handles.plotDAV = get(hObject,'Value');
guidata(hObject,handles)


function AscaleEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to AscaleEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AscaleEditBox as text
%        str2double(get(hObject,'String')) returns contents of AscaleEditBox as a double

handles.Ascale = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function AscaleEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AscaleEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%overlay DOQQ
msgbox('Adding Background','VMT Status','help','replace');
log_text = VMT_OverlayDOQQ(pwd);
msgbox('Replotting Complete','VMT Status','help','replace');


% --- Executes during object deletion, before destroying properties.
function PlotDAVcheckbox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to PlotDAVcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PlotDAVButton.
function PlotDAVButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotDAVButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Plot the DAV data
msgbox('Plotting Vectors...Please be patient','VMT Status','help','replace');
VMT_PlotDAVvectors(handles.VelOut(handles.goodrows,1),handles.VelOut(handles.goodrows,2),handles.VelOut(handles.goodrows,4),handles.VelOut(handles.goodrows,5),handles.Ascale,handles.Vspace,handles.units)
msgbox('Plotting Complete','VMT Status','help','replace');


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

handles.Vspace = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tav_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to tav_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tav_editbox as text
%        str2double(get(hObject,'String')) returns contents of tav_editbox as a double
handles.TAV = str2double(get(hObject,'String'));
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function tav_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tav_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
