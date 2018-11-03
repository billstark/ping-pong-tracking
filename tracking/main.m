addpath('./');

close all
clear all

VNameList = dir('TestVideos/CAM1-*.mp4');
for vidx = 1:length(VNameList)
    vname = strcat('TestVideos/', VNameList(vidx).name);
end



% Read video
VName = 'CAM1-GOPR0333-21157.mp4';
v = VideoReader(VName);
v1 = VideoReader(VName);
v2 = VideoReader(VName);
numberOfFrames = v2.numberOfFrames;
width = v2.width;
height = v2.height;



% Calculate averaged for background removal

averaged = double(readFrame(v1));
uint8_avg = uint8(averaged);
for i = 1 : (numberOfFrames-1)
    currentFrame = double(readFrame(v1));
    averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
end




firstFrame = readFrame(v);
secondFrame = readFrame(v);

detectedPoints = [];

for n = 1:(numberOfFrames - 2)
    firstFrame = firstFrame - uint8_avg;
    secondFrame = secondFrame - uint8_avg;

    % Find corners
    [r, c] = findCorner(firstFrame, 13, 5);

    % Dilate each corner, and erode, in order to shrink points near each other
    BW = zeros(height, width);
    for i = 1:size([r; c]', 1)
        x = r(i);
        y = c(i);
        BW(y, x) = 255;
    end
    dilate_val = 30;
    dilated = imdilate(BW, ones(dilate_val, dilate_val));
    eroded = bwmorph(dilated, 'shrink', Inf);
    [pos_r, pos_c] = find(eroded==1);
    
    detectedPoints = [detectedPoints; [pos_r, pos_c]];

%     imshow(firstFrame+uint8_avg);
%     hold on;
%     for i = 1:size(pos_r, 1)
%         x = pos_c(i);
%         y = pos_r(i);
%         rectangle('Position', [x - 6, y - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1)
%     end
%     print(strcat('out/f', num2str(n), '.jpg'), '-djpeg');

    firstFrame = secondFrame + uint8_avg;
    secondFrame = readFrame(v);
end



