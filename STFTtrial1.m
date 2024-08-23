clc
clear all;
warning('off', 'all');
bas=2e6;
for k= 1:2
sim('IDTmodel');
Va= VoltageCB1a.Data(1:end);
% Parameters
fs = 3840;  % Sampling frequency in Hz
window_length = 360;  % Window length for STFT
overlap = 0;  % Overlap between windows
nfft = 360;  % Number of FFT points

% Perform STFT and create spectrograms for each phase
figure;
% Compute STFT
[S, F, T] = spectrogram(Va, window_length, overlap, nfft, fs, 'yaxis');

% Plot spectrogram
imagesc(T, F, 10*log10(abs(S)));
axis xy;
ylabel('Frequency (Hz)');
ylim([0 700]);
% title(['Phase ', num2str(phase), ' Spectrogram']);
% colorbar;
% Create your figure
% plot(x, y);

% Specify the full path and filename
folderPath = 'C:\Users\Dell\Desktop\Project MSC Third Sem\Papers\MATLAB Files\Scripts\Datasets\Islanding';
fileName= [ num2str(k) '.jpg'];
fullPath = fullfile(folderPath, fileName);
saveas(gcf, fullPath);
bas=3e6;
end
