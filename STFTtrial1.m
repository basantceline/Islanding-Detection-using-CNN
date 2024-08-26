clear all;
%this bit of code is for variation in Active Power
% basw=[];
% perc=1;
% for k= 1:5
%     basw(1,end+1)=(((14*perc)^2-4.41)^0.5)-5.5;
%     perc=perc+0.01;
% end

%this code segment is for variation in Fault resistance at DL-1
res=[0.1 0.5];
for s=2:50
    res(1,end+1)=res(1,s)+0.5;
end


warning('off', 'all');
for d= 1:length(res)
R=res(1,d)
sim('IDTmodel');
Va= VoltageCB1a.Data(1:end);
Vb= VoltageCB1b.Data(1:end);
Vc= VoltageCB1c.Data(1:end);
voltage_data=[Va'; Vb'; Vc'];
% Parameters from the paper
Fs = 3840;  % Sampling frequency (Hz)
T = 0.75;   % Total simulation time (s)

% Generate time vector
t = 0:1/Fs:T-1/Fs;


% Parameters for STFT
window = hamming(256);  % Window function
noverlap = 0;         % Number of overlapped samples
nfft = 360;             % Number of FFT points

% Compute STFT for each phase and combine
S_phases = zeros(nfft/2+1, floor((length(t)-noverlap)/(length(window)-noverlap)), 3);
for phase = 1:3
    [S, F, T] = spectrogram(voltage_data(phase,:), window, noverlap, nfft, Fs, 'yaxis');
    S_phases(:,:,phase) = abs(S);
end
S_max = max(S_phases, [], 3); % Method 2: Maximum

% Plot spectrogram
figure;
imagesc(T, F, 20*log10(S_max));  % Convert to dB scale
axis xy;  % Put low frequencies at the bottom
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
ylim([0 1000]);
% title('Combined Three-Phase Voltage Spectrogram');
colorbar;
caxis([-60 20]);  % Adjust color scale as needed
% Save the spectrogram image
folderPath = 'C:\Users\Dell\Desktop\Project MSC Third Sem\MATLAB Files\Scripts\Datasets\Non-Islanding';
a=d+200;
fileName= [ num2str(a) '.png']
fullPath = fullfile(folderPath, fileName);
exportgraphics(gcf,fullPath,'Resolution',300);
end





