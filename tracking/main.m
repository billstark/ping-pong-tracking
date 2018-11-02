addpath('./');

close all
clear all

% Read video

VName = 'CAM1-GOPR0333-21157.mp4';
v = VideoReader(VName);
v1 = VideoReader(VName);
v2 = VideoReader(VName);
numberOfFrames = v2.numberOfFrames;



% Calculate averaged for background removal

averaged = double(readFrame(v1));
uint8_avg = uint8(averaged);
for i = 1 : (numberOfFrames-1)
    currentFrame = double(readFrame(v1));
    averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
end
imshow(uint8_avg);
print('background.jpg', '-djpeg');



% find corners in all frames

firstFrame = readFrame(v);
secondFrame = readFrame(v);

for n = 1:(numberOfFrames - 2)
    firstFrame = firstFrame - uint8_avg;
    secondFrame = secondFrame - uint8_avg;
    [r, c] = findCorner(firstFrame, 13, 5);

    % imshow(firstFrame + uint8_avg);
    % hold on;
    % for i = 1:size([r; c]', 1)
    %     x = r(i);
    %     y = c(i);
    %     rectangle('Position', [x - 6, y - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1)
    % end
    % print(strcat('f', num2str(n), '.jpg'), '-djpeg');

    firstFrame = secondFrame + uint8_avg;
    secondFrame = readFrame(v);
end
