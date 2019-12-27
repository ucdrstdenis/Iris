function [numWindows, windowMatrix] =  Window_Overlap(audioIn, winToApp, hop)
%% WindownOverlap returns and N * M matrix of N windows     %
%                 where M = length(winToApp)                %
%% Input:                                                   %    
%  audioIn  = 1 x K vector                                  %
%  winToApp = window to apply, i.e. hanning(512,'periodic') %
%  hop      = # of samples to shift each window.            %
%                                                           %
%% Output:                                                  %
%  numWindows    = the number of Windows (i.e N)            %
%  windowMatrix  = N X M matrix of Windows                  %
%                                                           %
%% Example usage                                            %
%  [Y,Fs]   = audioread('Maple.wav');                       %
%  winToApp = hanning(512, 'periodic')';                    %
%  [Nwin, Windows] = WindowIt(Y, winToApp, 512/4);          %
%                                                           %
%%
   if size(audioIn,1)>2,   audioIn =  audioIn'; end         % Make sure Input is a 1or2xK vector
   if size(winToApp,1)>1, winToApp = winToApp'; end         % Make sure windowToApply is a 1xN vector   
   numChan = size(audioIn,1);
   winSize = length(winToApp);                              % Get the window length                       
   if (hop==0)                                              % hop=0 means no overlap          
    numWindows = floor(length(audioIn)/winSize);            % Calculate # Windows with no overlap
   else                                                     % Otherwise use overlap
    numWindows = 1+fix((length(audioIn) - winSize)/ hop);   % Get the number of Windows using overlap              
   end                                                      % End Overlap Check 
   
   windowMatrix = zeros(numWindows, winSize,numChan);       % Pre-allocate output for speed
   %for c = 1:numChan
   for i = 0:(numWindows - 1)                               % For each window
       block   = audioIn(i*hop+1:i*hop+winSize);            % Grab each block of samples
       windowMatrix(i+1,:)  = block.*winToApp;              % Apply given window to the block and store result
   end                                                      % End for loop
%   end
   return                                                   % End Function