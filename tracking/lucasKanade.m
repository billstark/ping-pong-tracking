function [rowsNew, colsNew] = lucasKanade(oldFrame, newFrame, rows, cols)
%LUCASC Summary of this function goes here
%   Detailed explanation goes here
oldPyramid = createPyramid(oldFrame, 64, 5);
newPyramid = createPyramid(newFrame, 64, 5);
[rows, cols] = opticalFlow(oldPyramid, newPyramid, rows, cols, 17);
rowsNew = rows;
colsNew = cols;
end

function [rowsNew, colsNew] = opticalFlow(oldPyramid, newPyramid, rows, cols, kernelSize)
halfKSize = floor(kernelSize / 2);
scaledRows = scaleCoord(rows, size(oldPyramid, 2));
scaledCols = scaleCoord(cols, size(oldPyramid, 2));

d = zeros([size(rows, 1) 2]);
for i = 1:size(oldPyramid, 2)
    d = d * 2;
    I = oldPyramid{i};
    J = newPyramid{i};
    
    gx = [I(:, 2:size(I, 2)) - I(:, 1:size(I, 2) - 1) zeros([size(I, 1) 1])];
    gy = [I(2:size(I, 1), :) - I(1:size(I, 1) - 1, :); zeros([1, size(I, 2)])];
    Ixx = gx .* gx;
    Ixy = gx .* gy;
    Iyy = gy .* gy;
    
    for j = 1:size(rows, 1)
        IRow = scaledRows{i}(j);
        ICol = scaledCols{i}(j);
        
        % improve displacement constantly
        for k = 1:10
        
            intD = round(d);
            % check here if bugs
            JRow = IRow + intD(j, 1);
            JCol = ICol + intD(j, 0);

            gt = I(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize) - J(JRow - halfKSize:JRow + halfKSize, JCol - halfKSize:JCol + halfKSize);
            gtgxFull = gt .* gx;
            gtgx = sum(sum(gtgxFull(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize)));
            gtgyFull = gt .* gy;
            gtgy = sum(sum(gtgyFull(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize)));
            gxgx = sum(sum(Ixx(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize)));
            gxgy = sum(sum(Ixy(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize)));
            gygy = sum(sum(Iyy(IRow - halfKSize:IRow + halfKSize, ICol - halfKSize:ICol + halfKSize)));
            Z = [gxgx gxgy; gxgy gygy];
            b = [gtgx; gtgy];
            displacement = Z \ b;
            if norm(displacement) == 0
                break;
            end
            d(j, :) = d(j, :) + displacement';
        end
    end
end
% here d is of size 2, row_length
d = round(d');
rowsNew = rows + d(2, :);
colsNew = cols + d(1, :);
end

function scaled = scaleCoord(coordinates, numOfLevels)
scaled = {coordinates};
for i = 1:numOfLevels
    scaled = [{floor(coordinates ./ 2)} scaled];
    coordinates = floor(coordinates ./ 2);
end
end

function pyramid = createPyramid(frame, minSize, maxLevel)
pyramid = {frame};
while size(frame, 1) > minSize && size(frame, 2) > minSize && size(pyramid, 2) < maxLevel
    sub = subSample(frame);
    pyramid = [{sub} pyramid];
    frame = sub;
end
end

function sampledFrame = subSample(frame)
gaussianSample = imgaussfilt(frame, 1);
sampledFrame = zeros(floor(size(gaussianSample) ./ 2));
for i = 1:size(sampledFrame, 1)
    for j = 1:size(sampledFrame, 2)
        sampledFrame(i, j) = gaussianSample(i * 2 - 1, j * 2 - 1);
    end
end
end

