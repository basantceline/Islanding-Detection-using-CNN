clc;
% Define the base directory
baseDir = 'C:\Users\Dell\Desktop\Project MSC Third Sem\MATLAB Files\Scripts\Datasets';

% Define the subdirectories for Islanding and Non-Islanding images
islandingDir = fullfile(baseDir, 'Islanding');
nonIslandingDir = fullfile(baseDir, 'Non-Islanding');

% Create a custom datastore for preprocessing
imds = imageDatastore({islandingDir, nonIslandingDir}, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames', ...
    'ReadFcn', @(filename) preprocessImage(imread(filename)));

% Display some information about the datastore
fprintf('Total number of images: %d\n', numel(imds.Files));
fprintf('Labels: %s\n', strjoin(string(unique(imds.Labels)), ', '));

% Define a simpler CNN architecture
layers = [
    imageInputLayer([224 224 3])
    
    convolution2dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    
    globalAveragePooling2dLayer
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
];

% Split the data into training and validation sets
[trainingSet, validationSet] = splitEachLabel(imds, 0.7, 'randomized');

% Define training options (using CPU)
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', 12, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', validationSet, ...
    'ValidationFrequency', 30, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'cpu');

% Train the network
net = trainNetwork(trainingSet, layers, options);

% Classify validation images
[YPred, probs] = classify(net, validationSet);
accuracy = mean(YPred == validationSet.Labels);

fprintf('Validation Accuracy: %f%%\n', accuracy * 100);

% Confusion Matrix
figure
confusionchart(validationSet.Labels, YPred);
title('Confusion Matrix: Validation Data');

% ROC Curve
[X, Y, T, AUC] = perfcurve(validationSet.Labels, probs(:, 1), 'Islanding');
figure
plot(X, Y)
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title(sprintf('ROC Curve (AUC = %.2f)', AUC))

% Example usage of classifyNewImage:
classifyNewImage(net, 'C:\Users\Dell\Desktop\test images');

% Function definitions below this point

function preprocessedImg = preprocessImage(img)
    % Resize image to a smaller dimension
    img = imresize(img, [224 224]);
    % Convert to single precision and scale to [0, 1]
    img = im2single(img);
    % Normalize to zero mean and unit variance
    img = (img - mean(img(:))) / std(img(:));
    preprocessedImg = img;
end


function classifyNewImage(net, imagePath)
    img = imread(imagePath);
    img = preprocessImage(img);
    [label, prob] = classify(net, img);
    fprintf('Image classified as: %s\n', char(label));
    fprintf('Probability: %.2f%%\n', max(prob) * 100);
end