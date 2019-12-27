function varargout = Iris(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @Iris_OpeningFcn, ...
  'gui_OutputFcn',  @Iris_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


%% --- Executes just before Iris is made visible.
function Iris_OpeningFcn(Object, ~, Z, varargin)

% Z is shorthand for the main object to keep the lines short
% The letter was chosen with our professor's name in mind

Z.output = Object;                                          % Choose default command line output for GUI
[path2Me, ~,~] = fileparts([mfilename('fullpath') '.m']);   % Get file path
addpath(genpath(path2Me));                                  % Add all subfolders to the path
Z.version = '1.0';                                          % Version # used in About Popup

Z.status.isRecording = false;                               % Nothing is being recorded at the start
Z.status.isPlaying   = false;                               % Nothing is playing at the start
Z.status.xLim        = [];

[Y,Fs] = audioread('Load Effect.aiff');                     % Get the 'ding' noise ready for when the user loads a file
Z.lFx = audioplayer(Y,Fs);                                  % Create the 'ding' noise for playing
[X,Fs] = audioread('Complete.aif');                         % Get the tri-tone noise ready for when the user loads a file
Z.cFx = audioplayer(X,Fs);                                  % Create the tri-tone noise for playing
[S,Fs] = audioread('FileSaved.aiff');                       % Get the saveNoise noise ready for when the user loads a file
Z.sFx = audioplayer(S,Fs);                                  % Create saveNoise tri-tone noise for playing

[path2Me, ~,~] = fileparts([mfilename('fullpath') '.m']);
mp  =  strcat(path2Me,'/Music/');
x3  = '.mp3';
x4  = '.m4a'; 
xa  = '.aiff';
Z.song.pathList  = {[],mp,mp,mp,mp,mp,mp,mp,mp,mp,mp};      % List of file paths to match song menu
Z.song.extList   = {[],x4,xa,x4,x4,x4,x4,x4,x4,x4,x3};      % List of file extensions to match song menu
Z = initialize_GUI(Object,Z);                               % Initialize the GUI and parameter defaults
guidata(Object, Z);                                         % Update Z structure
% UIWAIT makes Iris wait for user response (see UIRESUME)
% uiwait(Z.figure1);
end

function varargout = Iris_OutputFcn(~, ~, Z)
varargout{1} = Z.output;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the GUI and set the defaults
%% To edit the main figure, just type: guide + open Iris.fig
%-----------------------------------------------------------

function Z = initialize_GUI(Object, Z)
Z.renderer = 'OpenGL';                                      % Likely source of cross-compatibility, experiment later
Z.song.song           = 'Select a Song';                    % Song selected in Dropdown menu
Z.song.ext            = 0;                                  % Extention of selected song
Z.song.filename       = 0;                                  % Filename  of selected song
Z.song.path           = 0;                                  % Pathname of selected song
Z.song.Fs             = 44100;                              % Initial guess of sampling Rate of Selected Song - determined after selection

Z.status.isRecording = false;                               % Initialize status vairables
Z.status.isPlaying   = false;
Z.status.xLim        = [];
Z.status.isZoom      = false;                               % Keep track of if zoomed in or not
                            
Z.opt.Fs             = 11025;                               % Default Recording Fs
Z.opt.bits           = 16;                                  % Decault Recording Option uses 16 bit quanitzation
Z.opt.nChan          = 1;                                   % Default Recording Option is mono
Z.opt.trim           = 69;                                  % Trim Loaded audio to 6 minutes max
Z.opt.autoZoom       = true;                                % Automatically Zoom to selection
Z.opt.selOnly        = false;                               % Play only the selected portion of audio
Z.opt.play           = 'Original';                          % Play Original/Modified RadioButton
Z.opt.loop           = false;

Z.opt.applyTimeCE    = false;                               % Apply Time Compression checked
Z.opt.applyPS        = false;                               % Apply Pitch Shift checked
Z.opt.applyTC        = false;                               % Apply Tempo Change checked
Z.opt.applyOct       = false;                               % Apply Octaves

Z.opt.oct1            = false;                              % Apply Octave + 1
Z.opt.oct2            = false;                              % Apply Octave + 2
Z.opt.oct3            = false;                              % Apply Octave - 1
Z.opt.oct4            = false;                              % Apply Octave - 2

Z.params.nfft  = 2048;                                      % Number of FFT points
Z.params.win   = hanning(Z.params.nfft, 'periodic')';       % Window to use
Z.params.hop   = Z.params.nfft/4;                           % Hop Size
Z.params.S    = 'end';                                      % When optimizing selection, change the end index
Z.params.array = [Z.params.nfft, Z.params.hop, Z.params.S]; % Hold the previous 3 parameters

Z.audio.Fs       = 44100;                                   % Default Audio Sampling Rate
Z.audio.nChans   = 2;                                       % Default Audio to Stereo
Z.audio.bits     = 16;                                      % Audio Bits
Z.audio.start    = 0;                                       % Audio Start Index
Z.audio.end      = 0;                                       % Audio End Index

Z.audio.filename = [];                                      % Holds original audio filename
Z.audio.path     = [];                                      % Holds original audio path
Z.audio.ext      = [];                                      % Holds original audio extension
Z.audio.isRec    = false;                                   % True if audio is a recording, false if otherwise
Z.audio.data     = [];                                      % Holds Audio Data
Z.audio.t        = [];                                      % Holds time vector
Z.audio.dataM    = [];                                      % Holds Manipulated Data
Z.audio.tM       = [];
Z.audio.isMod    = false;                                   % True if data has been modified
Z.audio.dataSel  = [];                                      % Holds currently selected data, 

Z.sel.isSel      = false;                                   % Is anything selected
Z.sel.isZoom2sel = false;
Z.sel.st         = 0;                                       % Starting index, based on Z.audio.data
Z.sel.end        = 0;                                       % Ending index, based on Z.audio.data

Z.FX.Compression = 1;                                       % Time Compression
Z.FX.Expansion   = 1;                                       % Time Expansion
Z.FX.TempoChng   = 1;                                       % Tempo Factor
Z.FX.PitchShft   = 0;                                       % Pitch Shift Factor
Z.FX.VolMod      = 1;                                       % Amplitude Scale Factor

set(Z.AutoZoom,          'Value', Z.opt.autoZoom);          % Put sliders where they need to be
set(Z.ExpansionSlider,   'Value', Z.FX.Expansion);
set(Z.CompressionSlider, 'Value', Z.FX.Compression);
set(Z.TempoChangeSlider, 'Value', Z.FX.TempoChng);
set(Z.PitchShiftSlider,  'Value', Z.FX.PitchShft);

set(Z.TempoChange,      'String', num2str(Z.FX.TempoChng));  % Set slider text to what it should be
set(Z.CompressionText,  'String', num2str(Z.FX.Compression));
set(Z.ExpansionText,    'String', num2str(Z.FX.Expansion));
set(Z.PitchShiftText,   'String', num2str(Z.FX.PitchShft));

set(Z.ApplyTimeCE,      'Value', Z.opt.applyTimeCE);        % set to False
set(Z.ApplyPitchShift,  'Value', Z.opt.applyPS);            % set to False
set(Z.ApplyTempoChange, 'Value', Z.opt.applyTC);            % set to False
set(Z.ApplyHarmonizer,  'Enable', 'off');                   % Turn harmonizer off until an octave is checked

set(Z.Octave1, 'Value', false);                             % uncheck octave boxes by default
set(Z.Octave2, 'Value', false);                             % uncheck octave boxes by default
set(Z.Octave3, 'Value', false);                             % uncheck octave boxes by default
set(Z.Octave4, 'Value', false);                             % uncheck octave boxes by default

set(Z.ApplyButton,      'Enable', 'off');
axes(Z.axes1);  
%set(gcf,'Renderer',Z.renderer);                             % Use OpenGL for faster rendering
grid(Z.axes1, 'on');                                        % Turn grid on
set(Z.axes1,'Color','black');                               % Make the graph black
set(Z.axes1, 'XColor', [1,1,1]);
set(Z.axes1, 'Ycolor', [1,1,1]);
set(Z.axes1, 'View', [0,90]);                               % Set the view in case user messed it up with rotate tool
set(Z.axes1, 'ButtonDownFcn', {@selectPoints, Z});          % Detect button down functions
set(Z.axes1,'NextPlot','replaceChildren');                  % Prevent plot() from overwriting the BUttonDownFcn settings

set(Z.axes2, 'View', [0, 90]);                              % Set the view in case user messed it up with rotate tool
set(Z.axes2,'Color','black');
set(Z.axes2, 'XColor', [1,1,1]);
set(Z.axes2, 'Ycolor', [1,1,1]);
grid(Z.axes2, 'on');

guidata(Object, Z);                                         % Update the handles structure
Z = update_waveForms(Object, Z);                            % Update the plots
update_GUI(Object, Z);                                      % Update available GUI controls
end

%% Update the available Buttons/sliders on the GUI
%-----------------------------------------------------------
function Z = update_GUI(Object, Z)                                    
% Update play Modified/Original Radio Buttons 
if Z.audio.isMod==false                                     % If audio hasn't been modified yet
  set(Z.PlayModified,'Enable','off') ;                      % Update enabled buttons
  set(Z.PlayModified, 'Value', false);
  set(Z.PlayOriginal, 'Value', true);
  set(Z.SaveAudio, 'Enable', 'off');
else                                                        % Otherwase,
  set(Z.PlayModified,'Enable','on');                        % allow 'Play Modified'
  set(Z.SaveAudio, 'Enable', 'on');
end

if Z.status.isRecording                                     % Check if currently recording
  set(Z.StopButton,     'Enable', 'on');                    % If yes enable the Stop button
  set(Z.RecordButton,   'Enable', 'off');                   % If yes disable the Record button
  set(Z.PlayButton,     'Enable', 'off');                   % If yes, disable the playButton
  set(Z.StopPlayButton, 'Enable', 'off');                   % If yes, disable the Stop-Play button
  set(Z.LoadNew,        'Enable', 'off');
  set(Z.LoadSong,       'Enable', 'off');
elseif Z.status.isPlaying                                   % If it's playing
  set(Z.RecordButton,   'Enable', 'off');                   % If playing, disable record button
  set(Z.StopButton,     'Enable', 'off');                   % If playing, disable record-stop button
  set(Z.PlayButton,     'Enable', 'off');                   % If playing, disable play button
  set(Z.StopPlayButton, 'Enable',  'on');                   % If yes, disable the playButton
  set(Z.LoadSong,       'Enable', 'off');                   % Disable the load song button
  set(Z.LoadNew,        'Enable', 'off');                   % Disable the load new song button
  set(Z.SongMenu,       'Enable', 'off');                   % Disable changing the song selection
  set(Z.ApplyButton,    'Enable', 'off');                   % Disable the apply button
  set(Z.SaveAudio,      'Enable', 'off');                   % Disable the audio
else                                                        % Otherwise
  if ~isempty(Z.audio.data)                                 % Make sure there's data loaded
        set(Z.PlayButton,     'Enable', 'on');
        
        set(Z.ApplyButton,    'Enable', 'on');
        
        set(Z.StopPlayButton, 'Enable', 'off');             % If yes, disable the Stop-Play
  else
        set(Z.StopPlayButton, 'Enable', 'off');             % If yes, disable the Stop-Play
        set(Z.PlayButton,     'Enable', 'off');       
        set(Z.ApplyButton,    'Enable', 'off');
  end
  set(Z.SongMenu,   'Enable','on');
  set(Z.LoadNew,    'Enable', 'on'); 
  i= get(Z.SongMenu,'Value');                               % Get the currently selectd item
  if ~(i-1)                                                 % Check to make sure not 'Select a Song'
    set(Z.LoadSong,'Enable','off');                         % If it is, disable the Load Selected Button
  else                                                      % Otherwise, 
    set(Z.LoadSong,'Enable','on');                            
  end 
  set(Z.RecordButton,'Enable', 'on');                       % Enable the record button
  set(Z.StopButton,  'Enable', 'off');                      % Disable the stop button
end

% Update PlaySelected portion only
if Z.sel.isSel==false                                       % If nothing is selected
  set(Z.PlaySelected,'Value', false);                       % Update the enabled butons
  set(Z.PlaySelected,'Enable','off');
  set(Z.ZoomButton,  'Enable','off');
else                                                        % Otherwise
  set(Z.PlaySelected,'Enable','on') ;                       % Enable 'Play Selected'
  if Z.sel.isZoom2sel==false
    set(Z.ZoomButton, 'Enable', 'on');
  else
    set(Z.ZoomButton, 'Enable', 'off');
  end
end

% Update Zoom buttons
if Z.status.isZoom==false                                   % If the X axis aren't zoomed in
  set(Z.ZoomOut, 'Enable', 'off');                          % Disable zoom out
else                                                        % Otherwise
  set(Z.ZoomOut, 'Enable', 'on');                           % Enable it
end
guidata(Object, Z);                                         % Update handles structure
end

%% Update The Plots
%-----------------------------------------------------------
function Z = update_waveForms(Object, Z)   
if ~isempty(Z.audio.t) && ~isempty(Z.audio.data)            % If there's audio data                     
  if Z.audio.isMod && strcmp(Z.opt.play, 'Modified')        % If the data is modified, and modified radio button selected
    data = Z.audio.dataM;                                   % Use the modified data
    t    = Z.audio.tM;                                      % Use the modified time axiss
  else 
    data = Z.audio.data;                                    % Otherwise use the audio data
    t    = Z.audio.t;                                       % Also use the original time axis
  end
  if Z.sel.isSel                                            % Check if anything is selected
    s = Z.sel.st;                                           % Get start + end indices
    e = Z.sel.end;

    plot(Z.axes1,t(s:e), data(s:e), 'g', 'Parent', Z.axes1);% Plot the selection in green
    hold(Z.axes1, 'on');                                    % Turn the hold on
    plot(Z.axes1,t(e+1:end),data(e+1:end),'c','Parent', Z.axes1);% Plot the
    plot(Z.axes1, t(1:s-1), data(1:s-1), 'c','Parent', Z.axes1);   
    hold(Z.axes1, 'off');
    if Z.opt.autoZoom || Z.sel.isZoom2sel || Z.status.isZoom% Check if auto-zoom is seleced
      Z.status.xLim = [t(s) t(e)];
      Z.status.isZoom = true;
      Z.sel.isZoom2sel = true;
    end
  else                                                      % If nothing is selected
    plot(Z.axes1, t, data, 'c');                            % Just plot the data normally
  end
  
  if ~isempty(Z.status.xLim)                                % Check if Xlimits set
    set(Z.axes1, 'Xlim', Z.status.xLim);
  else                                                      % if not
    Z.status.xLim=[min(t) max(t)];
    set(Z.axes1, 'Xlim', Z.status.xLim);
  end
  
  dW = max(data)-min(data);                                 % Used for sizing the y limits
  ymin = min(data)-0.1*dW;                                  % Y min
  ymax = max(data)+0.1*dW;                                  % Y max
  if ymin~=ymax
  set(Z.axes1,'Ylim', [ymin ymax]);                         % Set the y limits
  end
  axes(Z.axes2);                                            % Focus axes2
  spectrogram(data, 256, [],...                             % Plot the spectogram
    [], Z.audio.Fs, 'yaxis');
  view([0, 90]);                                           
     
end                                                         % End audio Datacheck
  
  set(Z.axes1, 'ButtonDownFcn', {@selectPoints, Z});        % Detect button down functions
  set(Z.axes1,'NextPlot','replaceChildren');                % Prevent plot() from overwriting the BUttonDownFcn settings
  grid(Z.axes1, 'on');
  set(Z.axes1,'Color','black');
  set(Z.axes1, 'XColor', [1,1,1]);
  set(Z.axes1, 'Ycolor', [1,1,1]);
  
  
  set(Z.axes2, 'View', [0, 90]);                            % Set the view in case user messed it up with rotate tool
  grid(Z.axes2, 'on');
  set(Z.axes2,'Color','black');                             % Make axes2 black and it's grid white
  set(Z.axes2, 'XColor', [1,1,1]);
  set(Z.axes2, 'Ycolor', [1,1,1]);
  set(Z.axes2, 'Zcolor', [1,1,1]);
  set(Z.axes2,'Xlim',get(Z.axes1,'Xlim'));                  % Use the same limits of the upper axis when not in play
  guidata(Object, Z);
end

%% Mouse Button Down Function for Axes 1 -------------------
function selectPoints(Object, ~, ~)
Z = guidata(Object);   
if Z.status.isPlaying, return; end
if ~isempty(Z.audio.data)                                   % Make sure there's something plotted first
  mouseButton = get(gcf,'SelectionType');                   % Get the mouse button clicked
  if ~strcmp(mouseButton,'normal')                          % Make sure it is 'left click'
    return; 
  end              
  coords1 = get(gca,'CurrentPoint');                        % Get 'down' coordinates
  box     = rbbox;                                          % Start drawing the box
  coords2 = get(gca,'CurrentPoint');                        % Get 'up' Coordinates

  strt = coords1(1,1:2);                                    % Start x,y point
  nd   = coords2(1,1:2);                                    % End x,y point  
    
  beg  = min(strt(1), nd(1));                               % Passed to select Audio
  nnd  = max(strt(1), nd(1));

  allLines = findall(Z.axes1,'type','line');                % Get all the  'lines' selected
  [data,~] = getDataInRect(strt, nd, allLines(1));          % Return the data points highlighted
  if ~isempty(data) && size(data,1)>500                     % As long as more than 500 samples have been selected
    Z.sel.isSel = true;                                     % Mark selection as true
    if strt(1)>=nd(1), Z.params.S = 'start';                % User lifted up button at earlier sample                         
    else Z.params.S = 'end'; end                            % User lifted up button at later sample
    Z.params.Ary = [Z.params.nfft Z.params.hop, Z.params.S];% Holds optomize selection parameters
    if (Z.audio.isMod && strcmp(Z.opt.play, 'Modified'))    % Check if audio has been modified yet and ' Modified' is selected
      data = Z.audio.dataM;                                 % If yes, use the modified data
    else                                                    % If not use the original data
      data = Z.audio.data;
    end
    
    [Z.audio.dataSel, Z.sel.st, Z.sel.end] = selectAudio(...
                          data, Z.audio.Fs,Z.opt.nChan,...  % Optomize the selection for processing
                                  beg,nnd,Z.params.array);  % Also return the starting and ending indices
  else
    Z.sel.isZoom2sel = false;                               % Otherwise clear out the selection variables
    Z.sel.isSel = false;
    Z.audio.dataSel = [];
    Z.sel.st=0;
    Z.sel.nd=0;
  end
guidata(Object, Z);                                         % Update Z structure
Z = update_waveForms(Object, Z);

set(Z.axes1, 'ButtonDownFcn', {@selectPoints, Z});          % Detect button down functions
set(Z.axes1,'NextPlot','replaceChildren');                  % Prevent plot() from overwriting the BUttonDownFcn settings
guidata(Object, Z);                                         % Update Z structure
update_GUI(Object, Z);                                      % Enable/Disable buttons appropriatley
end
end
 
function [dataInRect,dataInd] = getDataInRect( start, ennd, lines )
if ( start(1) < ennd(1) )                                   % Define low and high x and y values,
   lowX = start(1); highX = ennd(1);
else                                                        % Get the true start and end points, not the start + end ribbox returns
   lowX = ennd(1); highX = start(1);
end
 
if ( start(2) < ennd(2) )                                   % Continue start-end check
   lowY = start(2); highY = ennd(2);
else
   lowY = ennd(2); highY = start(2);
end
 
xdata = get(lines, 'XData');                                        
ydata = get(lines, 'YData');
 
xind = (xdata >= lowX & xdata <= highX);
yind = (ydata >= lowY & ydata <= highY);
 
dataInd = xind & yind;                                      % Indices where the x and y data points lie
dataInRect = [xdata(dataInd);ydata(dataInd)]';              % Return all of the data highlighted by the rectangle
 
end

%% Record Button
%-----------------------------------------------------------
function RecordButton_Callback(Object, ~, ~) 
  Z = guidata(Object);                                      % Grab the latest version of the structure
  Z = initialize_GUI(Object, Z);                            % Initialize the gui
try                                                         % Try to start recording
  Z.recObj = audiorecorder(Z.opt.Fs,Z.opt.bits,Z.opt.nChan);% Initialze audio recorder
  Z.audio.Fs      = Z.opt.Fs;                               % Store sampling rate
  Z.audio.nChans  = Z.opt.nChan;                            % Store mono or stereo
  Z.audio.bits    = Z.opt.bits;                             % Store quantization level
  record(Z.recObj);                                         % Start Recording
  Z.status.isRecording = true;                              % Set the recording status
  guidata(Object, Z);                                       % Apply GUI Changes  
  update_GUI(Object,Z);                                     % Update the GUI to disable buttons
catch                                                       % If there's an error
  ed = errordlg(['Error initilaizing audio input device!'...
    'Check audio card and microphone!'],'ERROR');
  waitfor(ed);                                               % Wait for user to click okay
  return
end
end

%% Stop Button
%-----------------------------------------------------------
function StopButton_Callback(Object, ~, Z)                  % --- Executes on button press in StopButton.
if Z.status.isRecording
  stop(Z.recObj);                                           % Stop Recording
  Z.status.isRecording = false;                             % Set the recording status
  Z.audio.data = getaudiodata(Z.recObj);                    % Get the waveform
  Z.audio.Fs = Z.opt.Fs;                                    % Save sampling frequency
  
  [Z.audio.data, Z.audio.start, ...
    Z.audio.end] = selectAudio(Z.audio.data,...
    Z.audio.Fs,...                                          % Optomize the selection
    2,0,length(Z.audio.data),...                            %
    Z.params.array);
  Z.audio.isRec = true;  
  Z.audio.t = (0:length(Z.audio.data)-1)/Z.audio.Fs;        % Calculate time vector
  Z.status.xLim = [];                                       % Clear the X limits    
 guidata(Object, Z);                                        % Apply Gui Changes
 Z = update_waveForms(Object, Z);                           % Update the plots
 update_GUI(Object, Z);                                     % Update the GUI
end
end

%% Load a New Audio File Callback 
%-----------------------------------------------------------
function LoadAudioButton_Callback(Object, ~, Z)
if (Z.audio.isMod||(~isempty(Z.audio.data) && Z.audio.isRec))
    button = questdlg(['Are you sure? You will lose any'... % Check that the user knows unsaved changes lost
           ' unsaved changes...'],'Load selection','Yes');
    if ~strcmp(button, 'Yes')                              
      return;
    end
end
Z = guidata(Object);                                        % Get the latest version of the structure
Z = initialize_GUI(Object, Z);                              % Clear arrays and re-initialize the GUI

% Get new file
[filename, pathname] = uigetfile( ...                       % Open a File Dialogue
{'*.wav;*.mp3;*.m4a;*.mp4;*.ogg;*.flac;*.au',...            % Allow only audio filetyles
 ['Audio Files (*.wav, *.mp3, *.m4a, *.mp4,'...
                 '*.ogg, *.flac, *.au)']},...
   'Select an audio file');                                 % WindowTitle'
 
 if filename                                                % If the user doesn't click cancel
  
  addpath(pathname);                                        % Add the path to the Project
  [~,~,ext] = fileparts(filename);                          % Grab the extension 
  
  info   = audioinfo([pathname filename]);                  % Get audio file information
  file    = strsplit(filename, '.');
  str2add = [file{1} ' - ' info.Artist];                    % String to add into the song list
  songList = get(Z.SongMenu,'String');                      % Get the songlist 
  
  if ~isempty(strcmp(str2add, songList))                    % Make sure it's not already in the list
    set(Z.SongMenu, 'Value',strcmp(str2add, songList));     % If it is, set the selction to it
    button = questdlg('Already in Song Menu, Reload?',...   % Ask if the user wants to reload it
                    'Reload selection','Yes');
    if strcmp(button, 'Yes')                                % If they click yes                   
      LoadSong_Callback(Object, ED, Z);                     % Load the song
    else
      return; 
    end                                                     % Otherwise return
  end
  
  Z.audio.filename = filename;                              % Store the filename
  Z.audio.path     = pathname;                              % Store the pathname
  Z.audio.ext      = ext;                                   % Store the extension
    
  songList{end+1}  = str2add;                               % Add it to the song list
  set(Z.SongMenu, 'String', songList);                      % Update the popup menu
  size(songList,1)
  set(Z.SongMenu, 'Value',size(songList,1));                % Add the loaded song title-Artist to the Bottom  
  Z.song.pathList{end+1} = Z.audio.path;                    % Save path into pathLIst
  Z.song.extList{end+1} =  Z.audio.ext;                     % Save extension into ext list
  
% Get Other Audio File Info 
 Z.audio.Fs = info.SampleRate;                              % Store the sampleRate
 if  strcmp(Z.audio.ext, '.wav')                            % Check if wav file
    Z.audio.bits = info.BitsPerSample;                      % Store Bits Per Sample
 end
 Z.audio.nChans = info.NumChannels;                         % Store stereo or mono
 Z.audio.Len    = info.TotalSamples;                        % Store Total Samples
 Z.audio.Dur    = info.Duration;                            % Store length

 % Load the song into the player
 if Z.audio.Fs*Z.opt.trim<Z.audio.Len                       % Check to make sure trim length less than file length
  Z.audio.data=audioread([pathname filename],...            % Read in the audio file
                          [1 Z.audio.Fs*Z.opt.trim]);       % and trim to length
 else
  Z.audio.data=audioread([pathname filename]);              % If not, load the entire file.
 end
 
    [Z.audio.data, Z.audio.start, Z.audio.end] =... 
           selectAudio(Z.audio.data, Z.audio.Fs,...
           Z.opt.nChan,0,length(Z.audio.data),...           % Optomize the selection
           Z.params.array);

    Z.audio.t = (0:length(Z.audio.data)-1)/Z.audio.Fs;      % Calculate time vector

 % Play finish sound and update GUI
 play(Z.lFx);                                               % Play Finished Loading Effect
 guidata(Object, Z);                                        % Apply Gui Changes
 Z = update_waveForms(Object, Z);                           % Update the plots
 update_GUI(Object, Z);                                     % Update the GUi
end
end

%% --- Executes on Load Selected Audio Button Press
%-----------------------------------------------------------
function LoadSong_Callback(Object, ~, ~)
% Get the selected song
Z = guidata(Object);
if (Z.audio.isMod||(~isempty(Z.audio.data) && Z.audio.isRec))
    button = questdlg(['Are you sure? You will lose any'... % Ask if the user wants to reload it
           ' unsaved changes...'],'Load selection','Yes');
    if ~strcmp(button, 'Yes')                               % Return from the function unless they click 'Yes'           
      return;
    end
end

Z = initialize_GUI(Object,Z);                               % Clear the vectors and re-initialize the GUI
songList = get(Z.SongMenu,'String');                        % Check to make sure 'Select a Song' isn't selected
i      = get(Z.SongMenu,'Value');
if ~(i-1) || Z.status.isPlaying                             % Also make sure nothing is playing
  return
end                                                     
n = strsplit(songList{i},' -');                             % Split up to get the name

% Deal with the file and OS stuff
filename = [Z.song.pathList{i} n{1} Z.song.extList{i}];
[Z.audio.path, Z.audio.filename, Z.audio.ext] =...          % Get file path/extension info
                                        fileparts(filename);
% Get the file information
info   = audioinfo(filename);                               % Get audio file information
Z.audio.Fs     = info.SampleRate;                           % Store FS
Z.audio.nChans = info.NumChannels;                          % Store stereo or mono
Z.audio.Len    = info.TotalSamples;                         % Store Total Samples
Z.audio.Dur    = info.Duration;                             % Store length
  
% Read in the audio file
 if Z.audio.Fs*Z.opt.trim<Z.audio.Len                       % Check to make sure trim length less than file length
  Z.audio.data=audioread(filename,...                       % Read in the audio file
                          [1 Z.audio.Fs*Z.opt.trim]);       % and trim to length
 else
  Z.audio.data=audioread(filename);                         % If not, load the entire file.
 end

if strcmp(Z.audio.ext, '.wav') 
   Z.audio.bits   = info.BitsPerSample;                     % Store Bits Per Sample
end

% Create the time vector and optomize the selection
Z.audio.t = (0:length(Z.audio.data)-1)/Z.audio.Fs;          % Calculate time vector
[Z.audio.data, Z.audio.start, ...
    Z.audio.end] = selectAudio(Z.audio.data,...
    Z.audio.Fs,...                                          % Optomize the selection
    Z.opt.nChan,0,length(Z.audio.data),...
    Z.params.array);
  
% Finish 
Z.sel.isSel = false;                                        % Just loaded, so nothing is selected yet
Z.audio.dataSel = [];                                       % Clear the selectiona rray

Z = update_waveForms(Object, Z);                            % Update the plots
play(Z.lFx);                                                % Play Finished Loading Effect
guidata(Object, Z);                                         % Apply Gui Changes
Z = update_GUI(Object, Z);                                  % Update the GUi
end


%% --- Executes on selection change in SongMenu.
%-----------------------------------------------------------
function SongMenu_Callback(Object, ~, Z)
songList = cellstr(get(Object,'String'));
i       = get(Object,'Value');
if ~(i-1) 
Z = update_GUI(Object, Z);                                  % Update the GUi
guidata(Object, Z);                                         % Apply Gui Changes
return;
end
n = strsplit(songList{i},' -');                             % Split up to get the name
Z.song.filename = [Z.song.pathList{i} n{1} Z.song.extList{i}];

[Z.song.path, ~, Z.song.ext] =...                           % Get file path/extension info
                             fileparts(Z.song.filename);
Z.song.song = songList{i};
info  = audioinfo(Z.song.filename);                         % Get Audio Info

Z.song.Fs = info.SampleRate;                                % Store the Sample Rate
guidata(Object, Z);                                         % Apply Gui Changes
update_GUI(Object, Z);                                      % Update the GUi
end

%% --- Executes on slider movement. -----------------------------------
function PitchShiftSlider_Callback(Object, ~, Z)
val = get(Z.PitchShiftSlider, 'Value'); 
val = round(val/0.01)*0.01;                                 
Z.FX.PitchShft = val;                                       % Store for quick usage when "Apply" clicked
set(Z.PitchShiftText, 'String', num2str(val));
guidata(Object, Z);
end

%% --- Pitch Shift Slider Text Box -----------------------------
function PitchShiftText_Callback(Object, ~, Z)
val = round(str2double(get(Object, 'String'))/0.01)*0.01;   % Get text, convert to #         
min = get(Z.PitchShiftSlider, 'Min');                       % Get the range of the slider
max = get(Z.PitchShiftSlider, 'Max');

if (val<=max && val >= min)                                 % Check it's within the range
  Z.FX.PitchShft = val;                                     % If yes, Store the value
  set(Object, 'String', num2str(val));                      % Set the text to the rounded value
  set(Z.PitchShiftSlider, 'Value', val);                    % Set the value of the slider
else                                                        % If not
  errordlg('Pitch Shift uses values -24.00 to 24.00',...    Throw an error
                                        'Fontsize',14);   
  val = num2str(get(Z.PitchShiftSlider, 'Value'));          % Get last good slider value
  set(Object, 'String', val);                               % Update the text to something valid
end
guidata(Object,Z);
end

%% --- Executes on TempoChange slider movement.
function TempoChangeSlider_Callback(Object, ~, Z)
  val = get(Z.TempoChangeSlider, 'Value'); 
  val = round(val / 0.25)*0.25; 
  set(Z.TempoChange, 'String', num2str(val));               % Set the TempoChangeText
  set(Z.TempoChangeSlider, 'Value', val);                   % Set Slider
  Z.FX.TempoChng = val;
  guidata(Object, Z);
end


%% --- TempoChange Slider Text Box -----------------------------
function TempoChange_Callback(Object, ~, Z)
val = str2double(get(Object, 'String'));                    % Get text, convert to #
val = round(val / 0.25)*0.25;
min = get(Z.TempoChangeSlider, 'Min');                      % Get the range of the slider
max = get(Z.TempoChangeSlider, 'Max');

if (val <= max && val >= min)                               % Check it's within the range
  set(Object, 'String', num2str(val));                      % Set the text to the nearest 0.25
  set(Z.TempoChangeSlider, 'Value', val);                   % Set the value of the slider
  Z.FX.TempoChange = val;                                   % Store for later on
else                                                        % If its outside the range
  errordlg('Use numbers in the range 0.25 to 8');           % Throw an error
  val = num2str(get(Z.TempoChangeSlider, 'Value'));         % Get last good slider value
  set(Object, 'String', val);                               % And update the text to something valid
end
guidata(Object, Z);
end

%% -- Executes on Change of Time Expansion Text
function ExpansionText_Callback(Object, ~, Z)
val = str2double(get(Object, 'String'));                    % Get text, convert to #
val = round(val);                                           % Round 
min = get(Z.ExpansionSlider, 'Min');                        % Get the range of the slider
max = get(Z.ExpansionSlider, 'Max');
if (val <= max && val >= min)                               % Check it's within the range
  set(Object, 'String', num2str(val));                      % Set the text 
  set(Z.ExpansionSlider, 'Value', val);                     % Set the value of the slider
  Z.FX.TempoChng = val;                                     % Store for later on
else                                                        % If its outside the range
  errordlg('Use integers in the range 1 to 8');             % Throw an error
  val = num2str(get(Z.ExpansionSlider, 'Value'));           % Get last good slider value
  set(Object, 'String', val);                               % And update the text to something valid
end
set(Z.ExpansionSlider, 'Value', val);
guidata(Object, Z);
end


%% --- Executes on slider movement.
function ExpansionSlider_Callback(Object, ~, Z)
val = get(Z.ExpansionSlider, 'Value'); 
Z.FX.Expansion = round(val);                                % Store for quick usage when "Apply" clicked
set(Z.ExpansionSlider, 'Value', Z.FX.Expansion);
set(Z.ExpansionText, 'String', num2str(Z.FX.Expansion));
guidata(Object, Z);
end

%% --- Executes on slider movement.
function CompressionSlider_Callback(Object, ~, Z)
val = get(Z.CompressionSlider, 'Value'); 
Z.FX.Compression = round(val);                              % Store for quick usage when "Apply" clicked
set(Z.CompressionSlider, 'Value', Z.FX.Compression);
set(Z.CompressionText, 'String', num2str(Z.FX.Compression));
guidata(Object, Z);
end

%% -- Executes on Change of Compression Text
function CompressionText_Callback(Object, ~, Z)
val = str2double(get(Z.CompressionText, 'String')); 
val = round(val);
min = get(Z.CompressionSlider, 'Min');                      % Get the range of the slider
max = get(Z.CompressionSlider, 'Max');
Z.FX.Compression = val;
if (val <= max && val >= min)                               % Check it's within the range
  set(Object, 'String', num2str(val));                      % Set the text 
  set(Z.CompressionSlider, 'Value', val);                   % Set the value of the slider
  Z.FX.Compression = val;                                   % Store for later on
else                                                        % If its outside the range
  errordlg('Use integers in the range 1 to 8');             % Throw an error
  val = num2str(get(Z.CompressionSlider, 'Value'));         % Get last good slider value
  set(Object, 'String', val);                               % And update the text to something valid
end
set(Z.CompressionSlider, 'Value', Z.FX.Compression);
guidata(Object, Z);
end

%% About Button
function AboutButton_Callback(~, ~, Z)                      % Displays when the about button is clicked
h = msgbox({'Iris: A Phase Vocoder'
    '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  'Robert St. Denis   &   Matthew Chun'
  'EEC 201 Winter 2014 Project'
  sprintf('Version %s', Z.version)
  ''
  '(In Greek mythology, Iris is the personification of the rainbow.   - Wikipedia)'},'About');
waitfor(h);
end

%% Record Options Menu
function RecOptButton_Callback(~, ~, Z)                     % Called when User Clicks 'Record Options' 
Fs = Z.opt.Fs;                                              % from the Options menu
nbits = Z.opt.bits;

prompt = {'Sampling rate (1000 - 44100 Hz):'                % Prompt for the sampling rate to use when recording
  'Bits per sample (8, 16, or 24):'};                       % As well as bits per sample
def = {num2str(Fs) num2str(nbits)};
answer = inputdlg(prompt,'Record options',[1 35],def);

end

%%
% --------------------------------------------------------------------
function Demo_M2F_Callback(Object, ~, ~)                    % Set the sliders and checkboxes appropriatley for 
                                                              
  Z = guidata(Object);                                      % for applying male to female effect
  set(Z.PitchShiftSlider, 'Value', 4);
  set(Z.PitchShiftText, 'String', num2str(4));
  
  set(Z.ExpansionSlider, 'Value', 1);
  set(Z.ExpansionText, 'String', num2str(1));  
  set(Z.CompressionSlider, 'Value', 1);
  set(Z.CompressionText, 'String', num2str(1));

  set(Z.TempoChangeSlider, 'Value', 1);
  set(Z.TempoChange, 'String', num2str(1));
  
  set(Z.ApplyTimeCE, 'Value', false);
  set(Z.ApplyTempoChange, 'Value', false);
  set(Z.ApplyPitchShift, 'Value', true);
  guidata(Object, Z);
  ApplyPitchShift_Callback(Object, Z,Z);
end

%%
% --------------------------------------------------------------------
function Demo_F2M_Callback(Object, ~, ~)                    % Set the sliders and checkboxes appropriatley for 
  Z = guidata(Object);
  set(Z.PitchShiftSlider, 'Value', -4);                     % for applying female to male effect
  set(Z.PitchShiftText, 'String', num2str(-4));
  
  set(Z.ExpansionSlider, 'Value', 1);                       % Set the Expansion Slider
  set(Z.ExpansionText, 'String', num2str(1));               % Set the expansion text
  set(Z.CompressionSlider, 'Value', 1);                     % Set the compression slider
  set(Z.CompressionText, 'String', num2str(1));             % Set the compression text

  set(Z.TempoChangeSlider, 'Value', 1);                     % Set the tempo slider
  set(Z.TempoChange, 'String', num2str(1));                 % Set the tempo text
  
  set(Z.ApplyTimeCE, 'Value', false);                       % uncheck apply Time Expansion/ Compression
  set(Z.ApplyTempoChange, 'Value', false);                  % Uncheck tempo change
  set(Z.ApplyPitchShift, 'Value', true);                    % Uncheck pitchShift
  guidata(Object, Z);                                       % Update the handles structure
  ApplyPitchShift_Callback(Object, Z,Z);                    % Use the slider callback to move the slider appropritaley
end

%% --- Executes on button press in PlayButton.
function PlayButton_Callback(Object, ~, ~)
Z = guidata(Object);                                        % Get the latest handles structure
if (Z.sel.isSel && Z.opt.selOnly)                           % If there is a selection, and play 'selected only' checked
  if strcmp(Z.opt.play, 'Modified')                         % If 'modified' radio button selected
    data = Z.audio.dataM(Z.sel.st:Z.sel.end);               % Use modified selected audio data
    tSt = Z.audio.tM(Z.sel.st);                             % Get the position for the playbar to start at
    tNd = Z.audio.tM(Z.sel.end);  
  else                                                      % Otherwise use the original data
    data = Z.audio.data(Z.sel.st:Z.sel.end);                % Use the original with with the selection points
    tSt = Z.audio.t(Z.sel.st);                              % Get the position for the playbar to start at
    tNd = Z.audio.t(Z.sel.end);
  end
    data2 = [data, zeros(1,2049)];                          % Add some extra samples so the live surf plot doesn't say 'Index out of bounds' towards the end of playback

else                                                        % Play the entire thing
  if strcmp(Z.opt.play, 'Original')                         % If play original
    data = Z.audio.data;                                    % Set data = the original audio
    data2 = [Z.audio.data, zeros(1, 2049)];
   tSt = min(Z.audio.t);                                    % Starting Playbar position
   tNd = max(Z.audio.t);
  else                                                      % Othewise play the modified audio
    data = Z.audio.dataM; 
    data2 = [Z.audio.dataM, zeros(1, 2049)];                % Add some extra samples so the surf plot doesn't say 'Index out of bounds'
   tSt = min(Z.audio.tM);                                   % Starting Playbar position
   tNd = max(Z.audio.tM);
  end
end                                                         % End 'if selected data'

Z.status.isPlaying = true;                                  % Set the status to playing
guidata(Object, Z);                                         % Update the handles structure 
Z = update_GUI(Object, Z);                                  % update the GUI accordingly

axes(Z.axes1);                                              % Setup time Domain plot 
set(gcf,'Renderer',Z.renderer);                             % Use OpenGL for faster rendering
set(gca,'NextPlot','replaceChildren');                      % Avoid overwriting plot settings
yLims = get(Z.axes1,'Ylim');                                % Get the Y limits
Z.playBar = line(tSt.*[1 1],yLims,'color','g');
music = audioplayer(data, Z.audio.Fs);                      % Create the player
Z.playerHandle = music;                                     % Put it in the handles structure so StopButton has access
guidata(Object, Z);                                         % Save the handle

axes(Z.axes2);                                              % Setup to plot PSD
set(Z.axes2,'Color','black');                               % Set the graph color to black
%set(Z.axes2,'DrawMode', 'fast');                            % This line only works if renderer is painters, by default we are using OpenGL
set(gca,'NextPlot','replaceChildren');                      % Make sure the graph changes aren't overwritten in each 'plot' command
[~, ~, ~, P]=spectrogram(data, 256, [], [], Z.audio.Fs);    % Check the total  spectrogram of everything that will be played
zx=max(max(10*log10(abs(P))));                              % so we know the max and min Z limits that will occur during playback
zm=min(min(10*log10(abs(P))));
[~, F, T, P]=spectrogram(data2(1:2048), 256, [], [], Z.audio.Fs); % Now get the first spectrogram image
surf(T,F,10*log10(abs(P)),'LineStyle','Parent',Z.axes2,...  % Plot it using surf, set the parent and plot style
          'none', 'FaceColor', 'interp', 'edgecolor','none');
axis tight manual;                                          % Keep limits tight with the data and don't overwrite the settings below
set(Z.axes2, 'ZLim', [zm zx]);                              % Set the Z limits so graph doesn't change lmits dynamically - it would be harder to see changes since ref point is changing
set(Z.axes2, 'YLim', [0 19.9e3]);                           % Don't plot past 20kHz to save comp time, expected max sampling rate is 44.1kHz, so this is okay
set(Z.axes2,'ZLimMode','manual');                           % Make sure the plot limits stick
set(Z.axes2,'YLimMode', 'manual');                          % Make sure the plot limits stick

guidata(Object, Z);                                         % Update the handles structure
Z.opt.loop=1;                                               % Set loop to one so we can enter the while loop, this is updated with the checkbox status at the end
while(Z.status.isPlaying && Z.opt.loop)
play(music);  tic;                                          % Start playing and timing
while strcmp(get(music,'Running'),'on')                     % While the music is playing
  now = tSt + toc;                                          % Get the the green playbar should be at
  set(Z.playBar,'XData',[now now],'Parent', Z.axes1);       % Set the green playbar's position
  drawnow;                                                  % update axes 1 with the data
  samp = get(music, 'CurrentSample');                       % Get the current sample being played from the player
  [~, F, T, P]=spectrogram(data2(samp:samp+2046), 256, ...  % Get the spectrogram properties of the current sample + 4096 samples
                                        [], [], Z.audio.Fs);% 
  surf(T,F,10*log10(abs(P)),'LineStyle', 'none',...         % Plot the PSD in dBs on axes 2
       'FaceColor', 'interp','edgecolor','none');
  view(-87,52);                                             % Make sure the camera view is set correctly
  drawnow;                                                  % Refresh the PSD graph
end
Z = guidata(Object);                                        % Get the latest version of handles to set 'Z.opt.loop' to the proper value
end
set(Z.playBar,'XData',[tSt tSt]);                           % When done playing set the playbar position to the start
Z.status.isPlaying=false;                                   % Set the status to false
guidata(Object, Z);                                         % Update the handles structure again
Z=update_waveForms(Object, Z);                              % Reset axes2 to use static Spectrum
update_GUI(Object, Z);                                      % Update the GUI buttons now that nothing is playing anymore
end

%% --- Executes on button press in StopPlayButton.
function StopPlayButton_Callback(Object, ~, ~)
Z = guidata(Object);                                        % Get current settings
stop(Z.playerHandle);                                       % Stop the player

set(Z.playBar,'XData',[min(Z.audio.t) min(Z.audio.t)]);     % Set the green playbar

Z.status.isPlaying=false;                                   
guidata(Object, Z);
update_GUI(Object, Z);
end

%% --- Executes on button press for ApplyButton. ----------------------
function ApplyButton_Callback(Object, ~, ~)
Z = guidata(Object);                                        % Get current settings


% Determine which data set to use
if ~Z.sel.isSel                                             % If nothing has been selected
  button = questdlg(['You currently have nothing selected'... % Ask if the user wants to reload it
           ' Are you sure you want to apply these changes'...
           ' to the entire audio clip?'],'Apply to All?',...
            'Yes');
  if ~strcmp(button, 'Yes')                                 % If nothing has been selected
    return;  
  end                   
  if (Z.audio.isMod && strcmp(Z.opt.play, 'Modified'))      % If the audio has been modified alread
     data  = Z.audio.dataM;
  else                                                      % Otherwise use the original audio for input
    if (Z.audio.isMod)
      button = questdlg(['You have already made modifications'...   % Ask if the user wants to reload it
           ' to this audio. Applying modifications to the original '...
           ' will overwrite your changes. Is this okay?'],'Is this Okay?',...
            'Yes');
    if ~strcmp(button, 'Yes')  return;  end                 % If they don't click yes, return 
    end
    data = Z.audio.data;                                    % Pick the data
  end
else
  if (Z.audio.isMod && strcmp(Z.opt.play, 'Modified'))      % If the audio has been modified already
    data = Z.audio.dataM(Z.sel.st:Z.sel.end);
  else                                                      % Otherwise use the original audio for input
    data = Z.audio.data(Z.sel.st:Z.sel.end);
  end  
end  

fxCount = 0;                                                % Keep track of how many effects applied
% Determine and Apply effects
% Time Compression
if Z.opt.applyTimeCE                                        % If apply time compression is checked
  Z.wB = waitbar(0,'0% Complete','Name','Applying Compression/Expansion',...
            'CreateCancelBtn',...                           % Display a waitbar
            'setappdata(gcbf,''canceling'',1)');
  data = resample(data,Z.FX.Expansion, Z.FX.Compression);   % Resample for expansion/compression
  waitbar(1, Z.wB, '100% Complete');                        % Display 'Done'
  delete(Z.wB);                                             % Delete the waitbar and increment fXcount
  fxCount = fxCount + 1;
end

%Pitch Shift                                                % If pitch shift checked
if Z.opt.applyPS
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...
          'ExecutionMode', 'fixedRate');                    % Start a timer to update the waitbar
  Z.wB = waitbar(0,'0% Complete','Name','Applying Pitch Shift',...
            'CreateCancelBtn',...                           % Create the waitbar
            'setappdata(gcbf,''canceling'',1)');
  Z.tim.TimerFcn = {@updateBar, Z.wB};                      % Set the timer properties
  guidata(Object, Z);                                       % Update the handles structure
  start(Z.tim);                                             % Start the timer
  data = pitchShift(data, Z.params.win, Z.FX.PitchShft, ... % Apply the actual pitch shift
                                          Z.params.hop); 
  stop(Z.tim);                                              % Finished shifting so stop the timer
  delete(Z.tim);                                            % Delete the timer
  waitbar(1, Z.wB, '100% Complete');                        % Show '100% Complete'
  delete(Z.wB);                                             % Delete the waitbar
  fxCount = fxCount + 1;                                    % Increment FX count
end

%TempoChange                                                % If tempo change checked
if Z.opt.applyTC
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...   % See the commends on pitsh shift above, same idea applies
          'ExecutionMode', 'fixedRate');
  Z.wB = waitbar(0,'0% Complete','Name','Applying Tempo Change',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');         
  Z.tim.TimerFcn = {@updateBar, Z.wB};
  guidata(Object, Z);
  start(Z.tim);
  data = tempoChange(data, Z.params.win, Z.FX.TempoChng, ...% Apply the tempo change
                                          Z.params.hop); 
  stop(Z.tim);                                              % Stop the timer, delete it, set the waitbar and delete it too
  delete(Z.tim);
  waitbar(1, Z.wB, '100% Complete');
  delete(Z.wB);
  fxCount = fxCount + 1;                                    % Keep track of the effects applied
end

%Octaves
if Z.opt.applyOct                                           % If octaves are checked
  if Z.opt.oct1
  
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...   % Start a timer %make a waitbar, %apply pitch shift
          'ExecutionMode', 'fixedRate');                    % + set its properties
  Z.wB = waitbar(0,'0% Complete','Name','Applying +1 Octave',... %make a waitbar,
            'CreateCancelBtn',...                           % apply pitch shift
            'setappdata(gcbf,''canceling'',1)');         
  Z.tim.TimerFcn = {@updateBar, Z.wB};
  guidata(Object, Z);
  start(Z.tim);
  data1 = pitchShift(data, Z.params.win, 12, ...
                                          Z.params.hop);    % Shift the data + 1 octave (12 semitones = +1 octave)
  stop(Z.tim);
  delete(Z.tim);
  data = data(1:length(data1))+(2/3)*data1;                 % +1 Octave tends to overwhelm the original sound, so scale it down a bit
  waitbar(1, Z.wB, '100% Complete');                        % Complete waitbar and then delete it
  delete(Z.wB);           
  end
  
  if Z.opt.oct2                                             % If + 2 octaves applied
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...   % make a timer
          'ExecutionMode', 'fixedRate');
  Z.wB = waitbar(0,'0% Complete','Name','Applying +2 Octave',...
            'CreateCancelBtn',...                           % Make a waitbar
            'setappdata(gcbf,''canceling'',1)');         
  Z.tim.TimerFcn = {@updateBar, Z.wB};
  guidata(Object, Z);                                       % Update the handles structure
  start(Z.tim);                                             % Start the timer + apply a pitch shift
  data2 = pitchShift(data, Z.params.win, 24, Z.params.hop); % (+24 semitones  = +2 octaves)
  data = data(1:length(data2))+(2/3)*data2;                 % +2 Octaves tends to overwhelm the original sound, so scale it down a bit                     
  stop(Z.tim);
  delete(Z.tim);
  waitbar(1, Z.wB, '100% Complete');
  delete(Z.wB);
  end
  
  if Z.opt.oct3                                             % If -1 octave is checked
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...   % Make a timer
          'ExecutionMode', 'fixedRate');
  Z.wB = waitbar(0,'0% Complete','Name','Applying -1 Octave',...
            'CreateCancelBtn',...                           % Make a waitbar
            'setappdata(gcbf,''canceling'',1)');         
  Z.tim.TimerFcn = {@updateBar, Z.wB};                      % Set timer properties
  guidata(Object, Z);                                       % Update the GUI structure
  start(Z.tim);                                             % Start the timer
  data3 = pitchShift(data, Z.params.win, -12, Z.params.hop);% Pitch shift (-12 semitones = -1 Octave)                              
  stop(Z.tim);                                              % Stop + Delete the timer
  delete(Z.tim);
  data = data + (4/3)*data3(1:length(data));                % -1 Octave tends to be harder to hear, so scale it up
  waitbar(1, Z.wB, '100% Complete');                        % Set the waitbar
  delete(Z.wB);                                             % Then delete it
  end
  if Z.opt.oct4                                             % If octave 4 is checked
  Z.tim = timer('Period', 0.05, 'TasksToExecute', 49, ...   % Make a timer
          'ExecutionMode', 'fixedRate');
  Z.wB = waitbar(0,'0% Complete','Name','Applying -2 Octave',... % Setup the waitbar
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');         
  Z.tim.TimerFcn = {@updateBar, Z.wB};                      % Set the timer properties and update the handles
  guidata(Object, Z);
  start(Z.tim);
  data4 = pitchShift(data, Z.params.win, -24, ...           % -24 semitones = -2 octaves 
                                          Z.params.hop);
  data = data+(4/3)*data4(1:length(data));                  % -2 Octaves tends to be harder to hear, so scale it up a bit
  stop(Z.tim);                                              % Stop the timer
  delete(Z.tim);
  waitbar(1, Z.wB, '100% Complete');                        % Set the waitbar to finished and then delete it
  delete(Z.wB);
  end 
end

for i = 1:fxCount                                           % each effect makes the sound appear quiter due to the remnant artifacts
  data = (5/4)*data;                                        % So make the overall data louder to compensate
end

% Insert edited audio back into it's source
if ~Z.sel.isSel                                             % If nothing has been selected
  Z.audio.dataM = data;                                     % Then the entire modification is the new data
else                                                        % Otherwise
  if ~Z.audio.isMod                                         % If data has not been modified alread
  Z.audio.dataM = [Z.audio.data(1:Z.sel.st -1), data, ...   % the use the original data as the source
                   Z.audio.data(Z.sel.end+1:end)];
  Z.sel.end = length([Z.audio.data(1:Z.sel.st -1) data])-1; % Update the end selection point since the time axis may change
    
  else                                                      % If data has already been modified
  Z.audio.dataM = [Z.audio.dataM(1:Z.sel.st -1), data, ...  % Then use the modified data as the source
                   Z.audio.dataM(Z.sel.end+1:end)];  
 Z.sel.end = length([Z.audio.dataM(1:Z.sel.st-1) data])-1;  % Update the end selection point since the time axis may change            
    
  end
end  
 
Z.audio.isMod=true;                                         % Mark the audio as modified  
Z.opt.play = 'Modified';                                    % Automatically move the radio button to 'Modified'
set(Z.PlayModified, 'Value', true);                         % Update the GUI
set(Z.PlayOriginal, 'Value', false);

Z.audio.tM = (0:length(Z.audio.dataM)-1)/Z.audio.Fs;        % Calculate the new time vector after modification
Z.status.xLim = [];                                         % Clear the limits
guidata(Object, Z);                                         % Update the handles with latest info
Z=update_waveForms(Object, Z);                              % Let this function set the limits and replot appropriatley
update_GUI(Object, Z);                                      %
play(Z.cFx);                                                % Play Apple 'Tri-Tone' When complete 
end

%% --------------------------------------------------------------------
function updateBar(tim, ~, wB)
j = get(tim, 'TasksExecuted');
waitbar(2*j / 100, wB, sprintf('%i%% Complete', 2*j));      % Update the waitbar each time the timer is called again
end

%% --------------------------------------------------------------------
function SaveAudioButton_Callback(Object, ~, ~)
Z = guidata(Object);
filename = Z.audio.filename;                                % Store the filename
pathname = Z.audio.path;                                    % Store the pathname
ext = Z.audio.ext;                                          % Store the extension
newname = ['~/Music/' filename '_modified' ext];
 
[file, path] = uiputfile({'*.wav;*.mp3;*.m4a;*.mp4;*.ogg;*.flac;*.au',...
  'Audio Files (*.wav, *.mp3, *.m4a, *.mp4, *.ogg, *.flac, *.au)';'*.*','All Files'},'Save File As...',...
          newname);
 if file                                                    % If the user doesn't click cancel
  audiowrite([path file], Z.audio.dataM, Z.audio.Fs);       % Write the audio to file using its original extension type
  play(Z.sFx);
 end
end


%% --- Executes on button press in ZoomButton.
function ZoomButton_Callback(Object, ~, ~)
Z = guidata(Object);                                        % Get latest version of handles structure
if (Z.sel.isSel==true)                                      % As long as data is selected
  Z.status.isZoom = true;                                   % Set the status vairables
  Z.sel.isZoom2sel = true;
  if Z.audio.isMod                                          % If the data is modified
    Z.status.xLim = [Z.audio.tM(Z.sel.st) Z.audio.tM(Z.sel.end)];% Use the modified time axis for selection
  else                                                      % If not
    Z.status.xLim = [Z.audio.t(Z.sel.st) Z.audio.t(Z.sel.end)]; % Use the
  end
  set(Z.axes1, 'Xlim', Z.status.xLim);
  if ~Z.status.isPlaying
    set(Z.axes2, 'Xlim', Z.status.xLim);
  end
  guidata(Object, Z);
  update_GUI(Object, Z);
end
end

%% --- Executes on button press in ZoomOut.
function ZoomOut_Callback(Object, ~, ~)
Z = guidata(Object);  
Z.status.isZoom   = false;                                  % Keep track of if zoomed in or not
Z.sel.isZoom2sel  = false;
 if (Z.audio.isMod && strcmp(Z.opt.play, 'Modified'))       % If audio has been modified and 'Modified' selected
  Z.status.xLim = [min(Z.audio.tM) max(Z.audio.tM)];        % Use the modified time axis
else
  Z.status.xLim = [min(Z.audio.t) max(Z.audio.t)];          % Otherwise use the original time axies
end


set(Z.axes1, 'Xlim', Z.status.xLim);                        % Set the axes1 limits 
if ~Z.status.isPlaying                                      % If nothing is playing
  set(Z.axes2, 'Xlim', Z.status.xLim);                      % Also set axes2 limits
end
guidata(Object, Z);                                         % Update the handles structure
update_GUI(Object, Z);                                      % Disable the ZOom out button since we've just zoomed out
end

%% --- Executes on button press in AutoZoom.
function AutoZoom_Callback(Object, ~, Z)                    % Just update the hanldes to keep track of autoZoom checkbox
Z.opt.autoZoom=get(Object,'Value');
guidata(Object,Z);
end

%% --- Executes on RadioButtonPreess in PlayModified.
function PlayModified_Callback(Object, ~, Z)                % Called when 'Modified' button has been ccalled
val = get(Object, 'Value');
set(Z.PlayOriginal, 'Value', ~val);                         % Set the 'Original' radiobutton to the opposite of the modifed button
if val Z.opt.play = 'Modified';                             % save the selection
else   Z.opt.play = 'Original'; end
guidata(Object,Z);                                          % Update the handles structure
Z.status.xLim = [];                                         % Clear the limits
Z.sel.isSel = false;                                        % Set the selection to false
Z = update_waveForms(Object, Z);                            % Update the original
update_GUI(Object, Z);
end

%% --- Executes on Radio Button Press in PlayOriginal.
function PlayOriginal_Callback(Object, ~, Z)
val = get(Object, 'Value');
set(Z.PlayModified, 'Value', ~val);
if val Z.opt.play = 'Original';
elseif strcmp(get(Z.PlayModified, 'Enable'), 'on')
  Z.opt.play = 'Modified';
end
Z.status.xLim = [];
Z.sel.isSel = false;
guidata(Object,Z);
Z = update_waveForms(Object, Z);
update_GUI(Object, Z);
end

%% --- Executes on button press in PlaySelectedOnly Toggle.
function PlaySelected_Callback(Object, ~, Z)
Z.opt.selOnly = get(Object, 'Value');
guidata(Object, Z);
end

%% --- Executes on button press in PlayLoop.
function PlayLoop_Callback(Object, ~, Z)
Z.opt.loop = get(Object, 'Value');
guidata(Object, Z);
end

%% --- Executes on button press in ApplyTimeCE.
function ApplyTimeCE_Callback(Object, ~, Z)
Z.opt.applyTimeCE = get(Object, 'Value');
if (Z.opt.applyTimeCE || Z.opt.applyPS || Z.opt.applyTC || Z.opt.applyOct)
  set(Z.ApplyButton, 'Enable', 'on');
else
  set(Z.ApplyButton, 'Enable', 'off');
end
guidata(Object, Z);
end

%% --- Executes on button press in ApplyPitchShift.
function ApplyPitchShift_Callback(Object, ~, Z)
Z = guidata(Object);
Z.opt.applyPS = get(Z.ApplyPitchShift, 'Value');
if (Z.opt.applyTimeCE || Z.opt.applyPS || Z.opt.applyTC || Z.opt.applyOct)
  set(Z.ApplyButton, 'Enable', 'on');
else
  set(Z.ApplyButton, 'Enable', 'off');
end
guidata(Object, Z);
end
%% --- Executes on button press in ApplyTempoChange.
function ApplyTempoChange_Callback(Object, ~, Z)
Z.opt.applyTC = get(Object, 'Value');
if (Z.opt.applyTimeCE || Z.opt.applyPS || Z.opt.applyTC || Z.opt.applyOct)
  set(Z.ApplyButton, 'Enable', 'on');
else
  set(Z.ApplyButton, 'Enable', 'off');
end
guidata(Object, Z);
end

function ApplyHarmonizer_Callback(Object, ~, Z)
Z.opt.applyOct = get(Object, 'Value');
if (Z.opt.applyTimeCE || Z.opt.applyPS || Z.opt.applyTC || Z.opt.applyOct)
  set(Z.ApplyButton, 'Enable', 'on');
else
  set(Z.ApplyButton, 'Enable', 'off');
end
guidata(Object, Z);
end

% --- Executes on button press in Octave1.
function Octave1_Callback(Object, ~, Z)
Z.opt.oct1 = get(Object, 'Value');
if (Z.opt.oct1 || Z.opt.oct2 || Z.opt.oct3 || Z.opt.oct4)
  set(Z.ApplyHarmonizer, 'Enable', 'on');
else
  set(Z.ApplyHarmonizer, 'Enable', 'off');
end

guidata(Object, Z);
end

% --- Executes on button press in Octave2.
function Octave2_Callback(Object, ~, Z)
Z.opt.oct2 = get(Object, 'Value');
Z.opt.oct1 = get(Object, 'Value');
if (Z.opt.oct1 || Z.opt.oct2 || Z.opt.oct3 || Z.opt.oct4)
  set(Z.ApplyHarmonizer, 'Enable', 'on');
else
  set(Z.ApplyHarmonizer, 'Enable', 'off');
end

guidata(Object, Z);
end

% --- Executes on button press in Octave3.
function Octave3_Callback(Object, ~, Z)
Z.opt.oct3 = get(Object, 'Value');
Z.opt.oct1 = get(Object, 'Value');
if (Z.opt.oct1 || Z.opt.oct2 || Z.opt.oct3 || Z.opt.oct4)
  set(Z.ApplyHarmonizer, 'Enable', 'on');
else
  set(Z.ApplyHarmonizer, 'Enable', 'off');
end

guidata(Object, Z);
end

% --- Executes on button press in Octave4.
function Octave4_Callback(Object, ~, Z)
Z.opt.oct4 = get(Object, 'Value');
Z.opt.oct1 = get(Object, 'Value');
if (Z.opt.oct1 || Z.opt.oct2 || Z.opt.oct3 || Z.opt.oct4)
  set(Z.ApplyHarmonizer, 'Enable', 'on');
else
  set(Z.ApplyHarmonizer, 'Enable', 'off');
end

guidata(Object, Z);
end



%% Used when Matlab requires a callback, but there's nothing to do.
function Dummy_Callback(~, ~, ~)
end


%% ----------------------------------------------------------
%%----------Matlab makes these, they're unused--------------
% --- Executes during object creation-----------------------
function TempoChangeSlider_CreateFcn(Object, ~, ~)
if isequal(get(Object,'BackgroundColor'),... 
           get(0,'defaultUicontrolBackgroundColor'))
           set(Object,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation-----------------------
function PitchShiftSlider_CreateFcn(Object, ~, ~)
if isequal(get(Object,'BackgroundColor'),... 
           get(0,'defaultUicontrolBackgroundColor'))
           set(Object,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation-----------------------
function ExpansionText_CreateFcn(Object, ~, ~)
if ispc && isequal(get(Object,'BackgroundColor'),... 
                   get(0,'defaultUicontrolBackgroundColor'))
                   set(Object,'BackgroundColor','white');
end
end

% --- Executes during object creation, ---------------------
function ExpansionSlider_CreateFcn(Object, ~, ~)
if isequal(get(Object,'BackgroundColor'),... 
           get(0,'defaultUicontrolBackgroundColor'))
           set(Object,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation-----------------------
function CompressionSlider_CreateFcn(Object, ~, ~)
if isequal(get(Object,'BackgroundColor'),... 
           get(0,'defaultUicontrolBackgroundColor'))
           set(Object,'BackgroundColor',[.9 .9 .9]);
end
end

% --- SongMenu Creation function-----------------------------
function SongMenu_CreateFcn(Object, ~, ~)
if ispc && isequal(get(Object,'BackgroundColor'), ...
                   get(0,'defaultUicontrolBackgroundColor'))
                   set(Object,'BackgroundColor','white');
end
end
% --- CompressionText Edit Text Box-------------------------
function CompressionText_CreateFcn(Object, ~, ~)
if ispc && isequal(get(Object,'BackgroundColor'),... 
                   get(0,'defaultUicontrolBackgroundColor'))
                   set(Object,'BackgroundColor','white');
end
end

% --- PitchShift Edit Text Box------------------------------
function PitchShiftText_CreateFcn(Object, ~, ~)
if ispc && isequal(get(Object,'BackgroundColor'),... 
                   get(0,'defaultUicontrolBackgroundColor'))
                   set(Object,'BackgroundColor','white');
end
end

% --- Create TempoChange Edit Text Box----------------------
function TempoChange_CreateFcn(Object, ~, ~)
if ispc && isequal(get(Object,'BackgroundColor'),... 
                  get(0,'defaultUicontrolBackgroundColor'))
                  set(Object,'BackgroundColor','white');
end
end
