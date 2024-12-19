function varargout = mapMakerGUI(varargin)
% mapMakerGUI MATLAB code for mapMakerGUI.fig
%      mapMakerGUI, by itself, creates a new mapMakerGUI or raises the existing
%      singleton*.
%
%      H = mapMakerGUI returns the handle to a new mapMakerGUI or the handle to
%      the existing singleton*.
%
%      mapMakerGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mapMakerGUI.M with the given input arguments.
%
%      mapMakerGUI('Property','Value',...) creates a new mapMakerGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapMakerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapMakerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mapMakerGUI

% Last Modified by GUIDE v2.5 21-Mar-2021 08:07:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapMakerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mapMakerGUI_OutputFcn, ...
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

% --- Executes just before mapMakerGUI is made visible.
function mapMakerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mapMakerGUI (see VARARGIN)

% Choose default command line output for mapMakerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Lmks LmkGraphics Wpts WptGraphics DefaultText AxisDim RunTime ...
    Obstacles ObstaclesMidpoint World

World = [];

Lmks = [];

LmkGraphics = line(...
    'parent',handles.mainAxes, ...
    'linestyle','none', ...
    'marker','+', ...
    'color','b', ...
    'xdata',[], ...
    'ydata',[]);

Wpts = [];

WptGraphics = line(...
    'parent',handles.mainAxes, ...
    'marker','o', ...
    'color','r', ...
    'xdata',[], ...
    'ydata',[]);

Obstacles = [];
ObstaclesMidpoint = [];

DefaultText = 'Select a command...';

AxisDim = 10;
%set(handles.mainAxes, 'XLim', [-AxisDim,AxisDim], 'YLim', [-AxisDim,AxisDim]);
axes(handles.mainAxes)
axis([-AxisDim AxisDim -AxisDim AxisDim])
axis square

set(handles.AxisDimVar, 'String', AxisDim)

RunTime = 400;
set(handles.RunTimeVar, 'String', RunTime)

obsVertices = 3;
set(handles.obsVertices, 'String', obsVertices)

obsVelX = 0; obsVelY = 0;
set(handles.obsVelX, 'String', obsVelX)
set(handles.obsVelY, 'String', obsVelY)

% imagesc([], 'parent', handles.map1);
set(handles.map1, 'XTick', [], 'YTick', [])
% imagesc([], 'parent', handles.map2);
set(handles.map2, 'XTick', [], 'YTick', [])

% UIWAIT makes mapMakerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mapMakerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in AddLmk.
function AddLmk_Callback(hObject, eventdata, handles)
% hObject    handle to AddLmk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Lmks AxisDim DefaultText
set(handles.helpBox, 'String', 'Click on the axes to place a landmark...')
clicked = 0;
while ~clicked
    [x,y]=ginputax(handles.mainAxes,1);
    if abs(x) < AxisDim && abs(y) < AxisDim
        Lmks = [Lmks [x;y]];
        axes(handles.mainAxes);
        %hold on
        plotItems(Lmks, 'landmarks');
        set(handles.helpBox, 'String', ...
            ['Landmark placed at:' char(10) ...
            '(' num2str(x) ', ' num2str(y) ')' char(10) DefaultText])
        clicked = 1;
    else
        set(handles.helpBox, 'String', ...
            'Landmark not placed! Click somewhere on the axes.')
    end
end

% --- Executes on button press in DelLmk.
function DelLmk_Callback(hObject, eventdata, handles)
% hObject    handle to DelLmk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Lmks AxisDim DefaultText
set(handles.helpBox, 'String', 'Click a landmark to delete...')
clicked = 0;
while ~clicked
    if ~isempty(Lmks)
        p = ginputax(handles.mainAxes,1);
        if abs(p(1))<AxisDim && abs(p(2))<AxisDim
            i = nearestNeighbour(Lmks, p);
            % Remove nearest neighbour from Lmks
            lmk_deleted = Lmks(:,i);
            Lmks(:,i) = [];

            axes(handles.mainAxes);
            hold on
            plotItems(Lmks, 'landmarks');

            set(handles.helpBox, 'String', ...
                ['Landmark deleted at:' char(10) ...
                '(' num2str(lmk_deleted(1)) ', ' num2str(lmk_deleted(2)) ')' ...
                char(10) DefaultText])
            clicked = 1;
        else
            set(handles.helpBox, 'String', ...
                'No landmarks deleted! Click somewhere on the axes.')
        end
    else
        set(handles.helpBox, 'String', ...
            ['No landmarks to delete.' char(10) DefaultText])
        clicked = 1;
    end
end

% --- Executes on button press in doSLAM.
function doSLAM_Callback(hObject, eventdata, handles)
% hObject    handle to doSLAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Lmks Wpts DefaultText AxisDim Obstacles World Map1 Map2
if isempty(Lmks) || isempty(Wpts) || isempty(Obstacles)
    errordlg(['The map must consist of at least 1 landmark,' ...
        '1 waypoint and 1 obstacle'],'BOOM!')
else
    set(handles.helpBox, 'String', 'Executing SLAM...')
    World = ekfSLAM(handles, AxisDim, Lmks, Wpts, Obstacles);
    set(handles.helpBox, 'String', ['SLAM simulation complete!' char(10) ...
        DefaultText])
    Map1 = World.gridmap_greyscale;
    Map2 = World.gridmap;
end

function plotItems(Items, ItemType)
global LmkGraphics WptGraphics
if strcmp(ItemType, 'landmarks')
    set(LmkGraphics, 'xdata', Items(1, :), 'ydata', Items(2, :))
elseif strcmp(ItemType, 'waypoints')
    set(WptGraphics, 'xdata', Items(1, :), 'ydata', Items(2, :))
end

function i = nearestNeighbour(Items, p)
diff2 = (Items(1,:)-p(1)).^2 + (Items(2,:)-p(2)).^2;
i= find(diff2 == min(diff2));
i= i(1);


% --- Executes on button press in LoadMap.
function LoadMap_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Lmks Wpts Obstacles ObstaclesMidpoint DefaultText
clearMap_Callback(hObject, eventdata, handles)
seed = {'*.mat','MAT-files (*.mat)'};
[fn,pn] = uigetfile(seed, 'Load Map');
if fn==0, return, end

fnpn = strrep(fullfile(pn,fn), '''', '''''');
load(fnpn)
Lmks = lmks;
Wpts = wpts;
Obstacles = obs;
if ~isempty(Lmks)
    plotItems(Lmks, 'landmarks');
end
if ~ isempty(Wpts)
    plotItems(Wpts, 'waypoints');
end
if ~isempty(Obstacles)
    for i = 1:length(Obstacles)
        Obstacles(i).plot(handles.mainAxes);
        ObstaclesMidpoint(:, i) = [mean(Obstacles(i).vertices(1,:)); ...
            mean(Obstacles(i).vertices(2,:))];
    end
end
