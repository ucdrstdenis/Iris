function  [aTempo, new_STFT] = phaseVocode(Windows, RC, hop)% Function: phaseVocode
%% PhaseVocoder takes in an N X M matrix of overlapped      %
% windows and alters the perceived rate of play             %
% without modifying the original frequency content.         %
%                                                           %
%% Inputs:                                                  %
% Windows = Matrix of windows                               %
% RC  = Rate Change <1 = slow down, >1 = speed up.          %
% Hop = The the space between window overlap                %
%                                                           %
%% Outputs:                                                 %
% aTempo = N*RC x M matrix of Windows                       %
%% $%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%$%
%                                                           %
 [N,winSize] = size(Windows);                               % Get the size of Windows Matrix
 Windows = [Windows; zeros(1, winSize)];                    % Add a buffer row
 t       = 0:RC:N-2;                                        % Get new basis for time (-2 bc start from 0 and need last two windows to inerpolate)
 fIndex  = 1:(winSize/2+1);                                 % Posotive frequency range indicis
 
 Spectra = fft(Windows,[],2);                               % Compute STFT of the Window Matrix
 Spectra = Spectra(:,fIndex);                               % Keep only posotive frequencies
 Mag     = abs(Spectra);                                    % Compute the magnitude
 aTempo  = zeros(length(t), winSize/2+1);                   % Preallocate Output
 ePhase  = zeros(1, winSize/2+1);                           % Preallocate expected phase change                  
 ePhase(2:end) = hop * 2*pi./(winSize./fIndex(1:end-1));    % Expected phase change in each window
 
 %% Interpolate magnitudes and phase correct each window
 phase = angle(Spectra(1,:));                               % Phase of the first window
 i = 1;                                                     % Iterator
 
 for t=t                                                    % For each new time basis i.e. t=[0, 0.8, 1.6, ... Nwindows]
  iWins  = floor(t) + [1 2];                                % Get index of the 2 windows closest to the current time basis
  Freqs  = Spectra(iWins, :);                               % FFT the windows
  Mags   =     Mag(iWins, :);                               % Also grab their magnitudes
  iw8t   = t-floor(t);                                      % Interpolation Weight
  iMag   = (1-iw8t)*Mags(1,:)+iw8t*Mags(2,:);               % Interpolated Magnitude  
  
  aTempo(i,:) = iMag.*exp(1i*phase);                        % Output = Interpolated Magnitude * e^jPhase
  dPhase = angle(Freqs(2,:)) - angle(Freqs(1,:)) - ePhase;  % Compute the phase change and remove the expected phase difference
  dPhase = dPhase - 2*pi*round(dPhase/(2*pi));              % Map to [-pi pi] range
  phase  = phase + dPhase + ePhase;                         % Cummulatively track the phase 
  i      = i+1;                                             % Increment Index
 end                                                        % End time basis loop
 new_STFT = [aTempo conj(fliplr(aTempo(:,2:end-1)))];       % Get back the full FFT (updated STFT) by concatenating the flipped conjucate of itself (excluding the sample at zero)
 aTempo = real(ifft(new_STFT,[],2));                        % Inverse FFT the result and delete any miniscule imaginary remaining parts
return                                                      % End Function