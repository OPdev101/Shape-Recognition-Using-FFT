%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ECE 3204 Computer Project – Pattern Recognition Using FFT %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pre-Processing Image (Train Image)
% Step 1: Read image
RGB = imread("Train Image\Train Image.png");

% Step 2: Convert image from RGB to grayscale
GRAY = rgb2gray(RGB);

% Step 3: Threshold the image
threshold = graythresh(GRAY);
BW = im2bw(GRAY, threshold);

% Step 4: Invert the Binary Image
BW = ~BW;

% Step 5: Find the boundaries
[B, ~] = bwboundaries(BW, 'noholes');

% Initialize variables
numShapes = length(B);  % Number of shapes in the image
contourPoints = cell(numShapes, 1);  % Cell array to store contour points for each shape

% Shape names
shapeNames = {'Half Stadium', 'Rectangle', 'Oval', 'Hexagon', 'Triangle', 'Star'};

%% Contour Points
% Set the desired number of contour points
% The better the number of contour points the better FFT plot.
numContourPoints = 300;

%% Pre-Processing Plots
% Plot figures for preprocessing
figure(1);
subplot(2, 2, 1);
imshow(RGB);
title('Original Image');

subplot(2, 2, 2);
imshow(GRAY);
title('Gray Image');

subplot(2, 2, 3);
imshow(BW);
title('Binary Image');

subplot(2, 2, 4);
imshow(~BW);
title('Inverted Binary Image');

%% Performing Shape Analysis

% Process each shape and plot remaining figures
shapesData = struct();  % Structure array to store shape data

for i = 1:numShapes
    % Get the x-y coordinates of the contour points
    contourPoints{i} = B{i};
    
    % Plot each shape and its contour points
    figure(i+1);
    subplot(1, 2, 1);
    imshow(BW);
    title(['Shape with Contour - ' shapeNames{i}]);
    hold on;
    plot(contourPoints{i}(:, 2), contourPoints{i}(:, 1), 'r', 'LineWidth', 2);
    hold off;
    
    % Step 6: Convert 2D coordinates to 1D array
    % Here, we'll calculate the Euclidean distance of each contour point from
    % the centroid of the shape to form a 1D array for each shape.
    
    % Calculate centroid
    centroid = mean(contourPoints{i});
    
    % Resample the contour to the desired number of points
    resampledContour = resampleContour(contourPoints{i}, numContourPoints);
    
    % Calculate Euclidean distances from centroid
    distances = sqrt(sum((resampledContour - centroid).^2, 2));
    
    % Step 7: Form a signal sequence x[n] for each shape
    % Here, we'll use the distances array as the signal sequence for simplicity.
    signalSequence = distances;
    
    % Step 8: Find the frequency spectrum using FFT
    % Perform FFT on the signal sequence x[n] for each shape
    spectrum = fft(signalSequence);
    
    % Step 9: Further processing and analysis for shape recognition
    % Here, we'll simply store the shape data in the structure array.

    % Store shape data
    shapesData(i).Name = shapeNames{i};
    shapesData(i).Centroid = centroid;
    shapesData(i).SignalSequence = signalSequence;
    shapesData(i).Spectrum = spectrum;
    
    % Display frequency spectrum
    subplot(1, 2, 2);
    semilogy(abs(spectrum));
    title(['Frequency Spectrum - ' shapeNames{i}]);
    
    % Step 10: Display results or save information for further analysis
    % Here, we'll display the shape number, name, and the centroid coordinates.
    fprintf('Shape %d - Name: %s - Centroid: (%.2f, %.2f)\n', i, shapeNames{i}, centroid(1), centroid(2));
end

%% IDENTIFICATION OF SHAPES FROM TEST IMAGES
% List of image file names
imageFiles = {
    'Test Images\Half Stadium.png',
    'Test Images\Half Stadium2.png',
    'Test Images\Hexagon.png',
    'Test Images\Hexagon2.png',
    'Test Images\Oval.png',
    'Test Images\Oval2.png',
    'Test Images\Rectangle.png',
    'Test Images\Rectangle2.png',
    'Test Images\Star.png',
    'Test Images\Star2.png',
    'Test Images\Triangle.png',
    'Test Images\Triangle2.png'
};

% Randomly shuffle the image file names
imageFiles = imageFiles(randperm(numel(imageFiles)));

% Process each image
for i = 1:numel(imageFiles)
    identifyShapeFromImage(imageFiles{i}, shapesData);
end