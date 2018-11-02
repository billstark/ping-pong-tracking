addpath('./');

close all
clear all

VName = 'CAM1-GOPR0333-21157.mp4';
v = VideoReader(VName);
v1 = VideoReader(VName);

averaged = double(readFrame(v1));
for i = 1 : floor(v1.FrameRate * v1.Duration - 1)
    currentFrame = double(readFrame(v1));
    averaged = ((i / (i + 1)) .* averaged) + ((1 / (i + 1)) .* currentFrame);
end
imshow(uint8(averaged));
print('background.jpg', '-djpeg');

firstFrame = readFrame(v);
secondFrame = readFrame(v);

for n = 1:floor(v.FrameRate * v.Duration - 1)
    firstFrame = firstFrame - uint8(averaged);
    secondFrame = secondFrame - uint8(averaged);
    [r, c] = findCorner(firstFrame, 13, 5);

    imshow(firstFrame + uint8(averaged));
    hold on;
    for i = 1:size([r; c]', 1)
        x = r(i);
        y = c(i);
        rectangle('Position', [x - 6, y - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1)
    end
    print(strcat('f', num2str(n), '.jpg'), '-djpeg');
    firstFrame = secondFrame + uint8(averaged);
    secondFrame = readFrame(v);
end
