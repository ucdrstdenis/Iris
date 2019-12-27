function audioOut = tempoChange(input, winToApp, rC, hopsize) 
%% TempoChange takes in an audio matrix and slows or increases its play  %%
% rate without increasing the frequency content                           %
%        Output:                                                          %
% shiftedAudio = pitch shifted audio file                                 %
%         Input:                                                          %
% input       = input matrix of windowed values                           %
% Fs          = sampling rate                                             %
% winToApp    = Window to apply                                           %
% step        = step in frequency desired to shift (i.e. half step)       %
% hopsize     = size of window overlap (winSize/4)                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %

[~, windowMatrix]     = Window_Overlap(input, winToApp, hopsize);         % Create windows and overlap them from music data
       [aTempo, ~]     = phaseVocode(windowMatrix, rC, hopsize);          % Shift pitch
          audioOut     = Overlap_Add(aTempo, winToApp, hopsize);          % Put windows into new vecotr
end