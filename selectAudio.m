function [selectedAudio, startTime, endTime] = selectAudio(Audio, Fs, varargin)
%% selectAudio takes in a Matrix of audio samples
% and their sampling frequency, Fs.
% Argument 3 = start time in seconds, defaults to 0
% Argument 4 = end time in seconds, defaults to 30 s 
% from the start time
% Argument 5 = # of Channels, 1 for mono, 2 for stereo
%              Defaults to # of channels in the Audio Matrix
% Argument 6 = vector of winsize,hop, and modify end
% parameters to ensure Optimal selection for windowing
%% Examples
% [Y, Fs] = audioread('Music.mp3');
% selectAudio(Y,Fs) OR     selects first 30 seconds
% selectAudio(Y,Fs,1) OR   selects first 30 seconds, conv to mono
% selctAudio(Y,Fs,2,0,50) OR selects first 50 seconds, uses stereo if available 
% selectAudio(Y,Fs,2,20,length(Y))
%%
%
[N,M]=size(Audio);                                          % Get Audio size

if (N>M) 
  Audio = Audio'; chan=M; samples=N;                        % Make sure in the form 2 x N
else
  chan=N; samples=M;
end                      

if ((nargin < 3)|| varargin{1}>=chan )                      % Check for # of channels to output
    numChannels = chan;                                     % numChannels = channels in original audio
else                                                        % If mono selected but audio is stereo
    Mono = (Audio(1,:) + Audio(2,:))/2;                     % Average Stereo
    Audio = Mono;                                           % Set Audio to mono
    numChannels = 1;                                        % Set the number of channels
end


if (nargin <4 || varargin{2}==0)                            % If startTime not provided or =0                                              
    startTime = 1;                                          % Use First Sample
else
    startTime = round(varargin{2}*Fs);                      % Convert to Samples
end

if nargin <5                                                % Check for endtime Argument
    endTime = startTime + Fs*30;                            % if no endTime, make end 30 seconds from start
else 
    endTime = round(varargin{3}*Fs);                        % Otherwise convert the endtime to samples
end

if nargin==6                                                % If we want to optimize selection for windowing
    params = varargin{4};
    winSize = params(1);
    hop     = params(2);
    sS      = params(3);
    leftover = mod(endTime-startTime+1 - winSize, hop);
    if leftover>=winSize/2
     if strcmp('end',sS) || (startTime-winSize+leftover)>1
          endTime = endTime + winSize - leftover;
     else startTime = startTime - winSize + leftover;
     end
    elseif (leftover<winSize/2 && leftover~=0)
     if strcmp('end',sS) || (startTime-leftover)<1
        endTime = endTime - leftover;
     else startTime = startTime - leftover;
     end
    end
end

if ((endTime - startTime)>samples)                          % Make sure audio is long enough to select
    endTime = samples;                                      % If not select as much as you can
end

 selectedAudio = zeros(numChannels, endTime-startTime+1);   %
 for i=1:numChannels
    selectedAudio(i,:) = Audio(i,startTime:endTime);
 end
return