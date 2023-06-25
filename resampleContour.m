% Helper function to resample the contour to the desired number of points
function resampledContour = resampleContour(contour, numPoints)
    % Calculate the total arc length
    distances = sqrt(sum(diff(contour).^2, 2));
    totalArcLength = sum(distances);

    % Calculate the desired arc length between each resampled point
    desiredArcLength = totalArcLength / (numPoints - 1);

    % Resample the contour based on the desired arc length
    resampledContour = zeros(numPoints, 2);
    resampledContour(1, :) = contour(1, :);
    remainingArcLength = 0;
    j = 2;

    for i = 1:size(contour, 1) - 1
        segmentLength = norm(contour(i, :) - contour(i+1, :));
        remainingArcLength = remainingArcLength + segmentLength;

        if remainingArcLength >= desiredArcLength
            resampledContour(j, :) = contour(i+1, :);
            j = j + 1;
            remainingArcLength = remainingArcLength - desiredArcLength;
        end
    end

    % Ensure that the last point of the contour is included
    resampledContour(end, :) = contour(end, :);
end