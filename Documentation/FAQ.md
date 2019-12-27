# Frequently Asked Questions

### Pitch-shifting is a ratio. What's a half-step?  
A half-step, also known as a semitone, is the smallest musical interval used in Western tonal music. It is defined as the interval between two adjacent notes in a 12-tone scale. One half-step is 100 cents, or one-twelfth of an octave.  As pitch-shifting is indeed a ratio, the desired shift must be converted from semitones (half-steps) to the desired tempo changing and re-sampling ratio. If 3.61 is entered into the pitch shift field, it implies the pitch should be shifted up  up by 361 cents, or 3.61 semitones. In Matlab syntax, the formula is:  

```matlab
ratio    = 2^(hStep/12);  
[r1, r2] = rat(ratio,1e-2);  
```  

In this case, the rationalize function rat() returns a ratio of 611/496, which is further approximated to 16/13 (a tolerance of 0.01) for simplicity. Because shifting the pitch up means slowing the song down by the inverse of the ratio and then re-sampling to the original duration, all that's required is to pass 13/16 as parameters to phaseVocode.m and resample.m.  


### How is the real-time PSD performed?  

The logic is fairly straightforward:  

```matlab
while strcmp(get(music,'Running'),'on')                     % While the music is still playing  
    sample  = get(music, 'CurrentSample');                  % Get the most recently played sample    
    lkAhead = data(sample:sample+2047);                     % Look ahead 2047 samples [2048 samples total]  
    [~, F, T, P] = spectrogram(lkAhead, 256,[],[], Fs);     % Get the spectrogram data    
    surf(T,F,10*log10(abs(P)));                             % Surf-plot the PSD in dBs   
end  
```  

The true implementation has some additional overhead, but the 6 lines above encompass the gist of it.  
For more, see PlayButton_Callback() in Iris.m  

### How was the vocoder's name chosen?
In Greek Mythology, Iris is the goddess of the rainbow & messenger of the gods.

