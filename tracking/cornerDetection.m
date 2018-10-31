function [row, col] = findCorner(img, kernelSize, numOfCorners)
% finds corners of the image
%   It uses Harris Corner detection to find the top k corners, where k is
%   specified by numOfCorners
img = int64(rgb2gray(img));
Ix = findIx(img);
Iy = findIy(img);
IMatrix = findMatrix(img, Ix, Iy, kernelSize);
detectedPoints = findSample(IMatrix, numOfCorners, kernelSize);
detectedPoints = detectedPoints';
row = detectedPoints(1, :);
col = detectedPoints(2, :);
end

function Iy = findIy(img)
% determines the pixel change along y axis
Iy = img(:, 2:size(img, 2)) - img(:, 1:size(img, 2) - 1);
Iy = [Iy zeros([size(img, 1), 1])];
end

function Ix = findIx(img)
% determines the pixel change along x axis
Ix = img(2:size(img, 1), :) - img(1:size(img, 1) - 1, :);
Ix = [Ix; zeros([1 size(img, 2)])];
end

function detectedMatrix = findMatrix(img, Ix, Iy, kernelSize)
Ixx = Ix .* Ix;
Iyy = Iy .* Iy;
Ixy = Ix .* Iy;
halfKSize = floor(kernelSize);
nRow = floor(size(img, 1) / (halfKSize + 1)) - 1;
nCol = floor(size(img, 2) / (halfKSize + 1)) - 1;
detectedMatrix = zeros(nRow, nCol, 2, 2, 'double');
for i = 1:size(img, 1)
    for j = 1:size(img, 2)
        if mod(i, halfKSize + 1) == 0 && mod(j, halfKSize + 1) == 0 && i - halfKSize > 0 && j - halfKSize > 0 && i + halfKSize <= size(img, 1) && j + halfKSize <= size(img, 2)
            detectedMatrix(i / (halfKSize + 1), j / (halfKSize + 1), 1, 1) = sum(sum(Ixx(i - halfKSize:i + halfKSize, j - halfKSize:j + halfKSize)));
            detectedMatrix(i / (halfKSize + 1), j / (halfKSize + 1), 1, 2) = sum(sum(Ixy(i - halfKSize:i + halfKSize, j - halfKSize:j + halfKSize)));
            detectedMatrix(i / (halfKSize + 1), j / (halfKSize + 1), 2, 1) = sum(sum(Ixy(i - halfKSize:i + halfKSize, j - halfKSize:j + halfKSize)));
            detectedMatrix(i / (halfKSize + 1), j / (halfKSize + 1), 2, 2) = sum(sum(Iyy(i - halfKSize:i + halfKSize, j - halfKSize:j + halfKSize)));
        end
    end
end
detectedMatrix = detectedMatrix ./ (kernelSize * kernelSize);
end

function accepted = findSample(detectedMatrix, numOfCorners, kernelSize)
    eigs = zeros(size(detectedMatrix, 1), size(detectedMatrix, 2), 'double');
    accepted = zeros(numOfCorners, 2, 'int64');
    floatMatrix = double(detectedMatrix);
    halfKSize = floor(kernelSize / 2);
    for i = 1:size(floatMatrix, 1)
        for j = 1:size(floatMatrix, 2)
            tempMatrix = zeros(2, 2, 'double');
            tempMatrix(1, 1) = floatMatrix(i, j, 1, 1);
            tempMatrix(1, 2) = floatMatrix(i, j, 1, 2);
            tempMatrix(2, 1) = floatMatrix(i, j, 2, 1);
            tempMatrix(2, 2) = floatMatrix(i, j, 2, 2);
            eigValues = eig(tempMatrix);
            eigs(i, j) = min(eigValues);
        end
    end
    reshapedEig = reshape(eigs, [], 1);
    sorted = sort(reshapedEig, 'descend');
%     disp(sorted(1:numOfCorners));
    for i = 1:numOfCorners
        selectedEig = sorted(i);
        [row, col] = find(eigs==selectedEig);
        accepted(i, 2) = row(1) * (halfKSize + 1);
        accepted(i, 1) = col(1) * (halfKSize + 1);
    end
end
