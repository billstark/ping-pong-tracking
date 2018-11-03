function detectedPoints = detectPoints(vname, averaged, crop)
    % Read video
    v = VideoReader(vname);
    v1 = VideoReader(vname);
    numberOfFrames = v1.numberOfFrames;
    width = v1.width;
    height = v1.height;


    firstFrame = imcrop(readFrame(v), crop);
    secondFrame = imcrop(readFrame(v), crop);

    detectedPoints = [];

    for n = 1:(numberOfFrames - 2)
        firstFrame = firstFrame - averaged;
        secondFrame = secondFrame - averaged;

        % Find corners
        [r, c] = findCorner(firstFrame, 13, 10);

        % % Dilate each corner, and erode, in order to shrink points near each other
        % BW = zeros(height, width);
        % for i = 1:size([r; c]', 1)
        %     x = r(i);
        %     y = c(i);
        %     BW(y, x) = 255;
        % end
        % dilate_val = 30;
        % dilated = imdilate(BW, ones(dilate_val, dilate_val));
        % eroded = bwmorph(dilated, 'shrink', Inf);
        % [pos_r, pos_c] = find(eroded==1);

        imshow(firstFrame + averaged);
        hold on;
        for i = 1:size([r; c]', 1)
            x = r(i);
            y = c(i);
            rectangle('Position', [x - 6, y - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1)
        end
        print(strcat('out/f', num2str(n), '.jpg'), '-djpeg');


        framePoints = [r' + crop(1), c' + crop(2)];
        detectedPoints = [detectedPoints; framePoints];

        folder_arr = strsplit(vname, '/');
        file_arr = strsplit(folder_arr{2}, '.');

        filename = file_arr{1};
        writePoints(framePoints, filename, n);

        firstFrame = secondFrame + averaged;
        secondFrame = imcrop(readFrame(v), crop);
    end
end