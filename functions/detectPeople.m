 function [centroids, bboxes, scores] = detectPeople(frame, scale, peopleDetectorDef)
        % Resize the image to increase the resolution of the pedestrian.
        % vision.PeopleDetector requires minimum size to operate.
        resizeRatio = scale;
        frame = imresize(frame, resizeRatio);

        % Run the people detector within a region of interest to produce
        % detection candidates.
        [bboxes, scores] = step(peopleDetectorDef, rgb2gray(frame));

%         % Look up the estimated height of a pedestrian based on location of their feet.
%         height = bboxes(:, 4) / resizeRatio;
%         y = (bboxes(:,2)-1) / resizeRatio + 1;
%         yfoot = min(length(pedScaleTable), round(y + height));
%         estHeight = pedScaleTable(yfoot);
% 
%         % Remove detections whose size deviates from the expected size,
%         % provided by the calibrated scale estimation.
%         invalid = abs(estHeight-height)>estHeight*option.scThresh;
%         bboxes(invalid, :) = [];
%         scores(invalid, :) = [];

        % Apply non-maximum suppression to select the strongest bounding boxes.
%         [bboxes, scores] = selectStrongestBbox(bboxes, scores, ...
%                             'RatioType', 'Min', 'OverlapThreshold', 0.7);

        % Compute the centroids
        if isempty(bboxes)
            centroids = [];
        else
            centroids = [(bboxes(:, 1) + bboxes(:, 3) / 2), ...
                (bboxes(:, 2) + bboxes(:, 4) / 2)];
        end
    end
