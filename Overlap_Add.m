function [audioOut] =  Overlap_Add(FramesIn, winToApp, hop)
%% WindownOverlap returns and N * M matrix of N windows     %
%                 where M = length(winToApp)                %
%% Input:                                                   %    
%  FramesIn  = 1 x K vector                                 %
%  winToApp = window to apply, i.e. hanning(512,'periodic') %
%  hop      = # of samples to overlap each window.          %
%                                                           %
%% Output:                                                  %
%  audioOut = 1 * M*N vector of reconsturcted samples       %
%                                                           %
%% Example usage                                            %
%  [Y,Fs]   = audioread('Maple.wav');                       %
%  winToApp = hanning(512, 'periodic')';                    %
%  [Nwin, Windows] = WindownOverlap(Y, winToApp, 512/4);    %
%                                                           %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
 if size(winToApp,1)>1, winToApp = winToApp'; end           % Make sure windowToApply is a 1xN vector   
 [N, winSize] = size(FramesIn);                             % Get the size of FramesIn 
     winToApp = 2/3*winToApp;                               % Scale Ouput 
      
     audioOut = zeros(1, hop*(N-1) + winSize);              % Preallocate the output for speed            
 for i = 0:(N - 1)                                          % For each Frame
       n = i*hop+1;                                         % Start Index
       m = n + winSize-1;                                   % End Index
       block   = FramesIn(i+1,:).*winToApp;                 % Apply WIndow
       audioOut(n:m) =  audioOut(n:m) + block;              % Overlap and Add
 end                                                        % End for loop
return                                                      % ENd Function;