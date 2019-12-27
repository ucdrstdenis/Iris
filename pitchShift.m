function shiftedAudio = pitchShift(input, winToApp, hStep, hopsize) 
%% Pitchshift takes a matrix & shifts the audio by the desired freqeuncy %%
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
            %  nfft         = 4096;                                       % Define the length of the window
          %winToApp         = hanning(nfft, 'periodic')';                 % Create Hanning Window for overlapping etc.. 
          [r2, r1]     = rat(2^((hStep*100)/1200),1e-2);                  % Find ratio values given by overtone series to shift pitch
 [~, windowMatrix]     = Window_Overlap(input, winToApp, hopsize);        % Create windows and overlap them from music data
       [aTempo, ~]     = phaseVocode(windowMatrix, r1/r2, hopsize);       % Shift pitch
        [audioOut]     = Overlap_Add(aTempo, winToApp, hopsize);          % Put windows into new vecotr
      shiftedAudio     = resample(audioOut,r1,r2);                        % Resample to adjust for pitch change
end