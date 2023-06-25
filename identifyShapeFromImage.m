function identifyShapeFromImage(imagePath, shapesData)
    % Read the uploaded image
    uploadedImage = imread(imagePath);

    % Convert the uploaded image from RGB to grayscale
    uploadedGray = rgb2gray(uploadedImage);

    % Threshold the uploaded image
    threshold = graythresh(uploadedGray);
    uploadedBW = im2bw(uploadedGray, threshold);

    % Invert the binary image
    uploadedBW = ~uploadedBW;

    % Find the boundaries of the uploaded image
    [B, ~] = bwboundaries(uploadedBW, 'noholes');

    % Initialize variables
    numShapes = length(B);  % Number of shapes in the uploaded image
    contourPoints = cell(numShapes, 1);  % Cell array to store contour points for each shape

    % Shape names
    shapeNames = {'Half Stadium', 'Rectangle', 'Oval', 'Hexagon', 'Triangle', 'Star'};

    % Process each shape
    for i = 1:numShapes
        % Get the x-y coordinates of the contour points
        contourPoints{i} = B{i};

        % Convert 2D coordinates to 1D array
        centroid = mean(contourPoints{i});

        % Resample contour to desired number of points
        numContourPoints = numel(shapesData(1).SignalSequence);  % Get the number of contour points used in stored shape data
        resampledContour = resampleContour(contourPoints{i}, numContourPoints);

        distances = sqrt(sum((resampledContour - centroid).^2, 2));
        signalSequence = distances;

        % Perform FFT on the signal sequence
        spectrum = fft(signalSequence);

        % Match the spectrum with stored shape data
        bestMatch = '';
        bestScore = inf;

        for j = 1:numel(shapesData)
            storedSpectrum = shapesData(j).Spectrum;
            score = norm(abs(spectrum) - abs(storedSpectrum));

            if score < bestScore
                bestScore = score;
                bestMatch = shapesData(j).Name;
            end
        end

        % Display the identified shape
        fprintf('\n\n**********************************\n')
        fprintf('Identified Shape: %s\n', bestMatch);
        fprintf('**********************************\n')

        % Plot the uploaded image with the identified shape
        figure;
        imshow(uploadedImage);
        hold on;
        plot(resampledContour(:, 2), resampledContour(:, 1), 'r', 'LineWidth', 2);
        text(centroid(2), centroid(1), bestMatch, 'Color', 'green', 'HorizontalAlignment', 'center');
        hold off;
        title('Identified Shape');
    end
end